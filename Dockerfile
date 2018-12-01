#
# BUILD    : DF/[ATLASSIAN][JIRA]
# OS/CORE  : dunkelfrosch/alpine:3.7
# SERVICES : ntp, ...
#
# VERSION 1.0.6
#

FROM dunkelfrosch/alpine:3.7
MAINTAINER Patrick Paechnatz <patrick.paechnatz@gmail.com>

ARG ISO_LANGUAGE=en
ARG ISO_COUNTRY=US
ARG JIRA_VERSION=7.13.0
ARG JIRA_PRODUCT=jira-software
ARG MYSQL_CONNECTOR_VERSION=5.1.46
ARG BUILD_DATE=undefined

ENV TERM="xterm" \
    TIMEZONE="Europe/Berlin" \
    JIRA_CROWD_SSO=false \
    JIRA_CONTEXT_PATH=ROOT \
    JIRA_HOME=/var/atlassian/jira \
    JIRA_INSTALL=/opt/jira \
    JIRA_SCRIPTS=/usr/local/share/atlassian \
    MYSQL_CONNECTOR_URL="http://dev.mysql.com/get/Downloads/Connector-J" \
    DOWNLOAD_URL="https://www.atlassian.com/software/jira/downloads/binary" \
    RUN_USER=jira \
    RUN_GROUP=jira \
    RUN_UID=1000 \
    RUN_GID=1000

ENV JAVA_HOME=$JIRA_INSTALL/jre
ENV PATH=$PATH:$JAVA_HOME/bin \
    LANG=${ISO_LANGUAGE}_${ISO_COUNTRY}.UTF-8

COPY scripts/* ${JIRA_SCRIPTS}/

# prepare directories
RUN mkdir -p ${JIRA_HOME}/caches/indexes \
             ${JIRA_INSTALL}/conf/Catalina \
             ${JIRA_INSTALL}/lib

RUN export JIRA_BIN=atlassian-${JIRA_PRODUCT}-${JIRA_VERSION}-x64.bin && \
    export KEYSTORE=$JAVA_HOME/lib/security/cacerts && \
    apk add --update ca-certificates gzip curl tini wget xmlstarlet && \
    wget -O /tmp/jira.bin https://www.atlassian.com/software/jira/downloads/binary/${JIRA_BIN} && chmod +x /tmp/jira.bin && \
    /tmp/jira.bin -q -varfile ${JIRA_SCRIPTS}/response.varfile && \
    rm -f ${JIRA_INSTALL}/lib/mysql-connector-java*.jar && \
    wget -O /tmp/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz && \
    tar xzf /tmp/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz --directory=/tmp && \
    cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar ${JIRA_INSTALL}/lib/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar && \
    addgroup -g $RUN_GID $RUN_GROUP && \
    adduser  -u $RUN_UID -G $RUN_GROUP -h /home/$RUN_USER -s /bin/bash -S $RUN_USER && \
    wget -P /tmp/ https://letsencrypt.org/certs/letsencryptauthorityx1.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/letsencryptauthorityx2.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x2-cross-signed.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x4-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias isrgrootx1 -file /tmp/letsencryptauthorityx1.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias isrgrootx2 -file /tmp/letsencryptauthorityx2.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx1 -file /tmp/lets-encrypt-x1-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx2 -file /tmp/lets-encrypt-x2-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx3 -file /tmp/lets-encrypt-x3-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx4 -file /tmp/lets-encrypt-x4-cross-signed.der && \
    wget -O /home/${RUN_USER}/SSLPoke.class https://confluence.atlassian.com/kb/files/779355358/779355357/1/1441897666313/SSLPoke.class && \
    chown -R ${RUN_USER}:${RUN_GROUP} ${JIRA_HOME} ${JIRA_INSTALL} ${JIRA_SCRIPTS} /home/${RUN_USER}

RUN apk del ca-certificates gzip wget && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* &&  \
    rm -rf /var/log/*

# ---------------------------------------------------------------------------------------------------------------------
# define image ext labels
# ---------------------------------------------------------------------------------------------------------------------
LABEL com.container.vendor="dunkelfrosch impersonate" \
      com.container.service="atlassian/jira" \
      com.container.service.verion="${JIRA_VERSION}" \
      com.container.priority="1" \
      com.container.project="jira" \
      img.builddate="${BUILD_DATE}" \
      img.version="1.0.6" \
      img.description="atlassian jira application container"

# ---------------------------------------------------------------------------------------------------------------------
# define container execution behaviour
# ---------------------------------------------------------------------------------------------------------------------

USER ${RUN_USER}:${RUN_GROUP}
WORKDIR ${JIRA_HOME}
VOLUME ["/var/atlassian/jira"]
EXPOSE 8080
ENTRYPOINT ["/sbin/tini","--","/usr/local/share/atlassian/entrypoint.sh"]
CMD ["jira"]
