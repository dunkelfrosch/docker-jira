#
# BUILD    : DF/[ATLASSIAN][JIRA]
# OS/CORE  : dunkelfrosch/alpine-jdk8
# SERVICES : ntp, ...
#
# VERSION 1.0.4
#

FROM blacklabelops/alpine:3.7

MAINTAINER Patrick Paechnatz <patrick.paechnatz@gmail.com>
LABEL com.container.vendor="dunkelfrosch impersonate" \
      com.container.service="atlassian/jira" \
      com.container.service.verion="7.9.1" \
      com.container.priority="1" \
      com.container.project="jira" \
      img.version="1.0.4" \
      img.description="atlassian jira application container"

ARG ISO_LANGUAGE=en
ARG ISO_COUNTRY=US
ARG JIRA_VERSION=7.9.1
ARG JIRA_PRODUCT=jira-software
ARG MYSQL_CONNECTOR_VERSION=5.1.46
ARG DOCKERIZE_VERSION=v0.6.1

ENV TERM="xterm" \
    TIMEZONE="Europe/Berlin" \
    JIRA_USER=jira \
    JIRA_GROUP=jira \
    JIRA_CONTEXT_PATH=ROOT \
    JIRA_HOME=/var/atlassian/jira \
    JIRA_INSTALL=/opt/jira \
    JIRA_SCRIPTS=/usr/local/share/atlassian \
    JVM_MYSQL_CONNECTOR_URL="http://dev.mysql.com/get/Downloads/Connector-J" \
    DOWNLOAD_URL="https://www.atlassian.com/software/jira/downloads/binary" \
    RUN_USER=jira \
    RUN_GROUP=jira \
    RUN_UID=1000 \
    RUN_GID=1000

ENV JAVA_HOME=$JIRA_INSTALL/jre

ENV PATH=$PATH:$JAVA_HOME/bin \
    LANG=${ISO_LANGUAGE}_${ISO_COUNTRY}.UTF-8

COPY scripts/* ${JIRA_SCRIPTS}/

RUN set -e && \
    apk add --update ca-certificates gzip curl tar xmlstarlet wget tzdata bash tini && \
    /usr/glibc-compat/bin/localedef -i ${ISO_LANGUAGE}_${ISO_COUNTRY} -f UTF-8 ${ISO_LANGUAGE}_${ISO_COUNTRY}.UTF-8 && \
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" >/etc/timezone

RUN mkdir -p ${JIRA_HOME}/caches/indexes \
             ${JIRA_INSTALL}/conf/Catalina \
             ${JIRA_INSTALL}/lib && \
    export JIRA_BIN=atlassian-${JIRA_PRODUCT}-${JIRA_VERSION}-x64.bin && \
    echo https://www.atlassian.com/software/jira/downloads/binary/${JIRA_BIN} && \
    wget -q -P /tmp/ https://www.atlassian.com/software/jira/downloads/binary/${JIRA_BIN} && \
    mv /tmp/${JIRA_BIN} /tmp/jira.bin && chmod +x /tmp/jira.bin

RUN /tmp/jira.bin -q -varfile ${JIRA_SCRIPTS}/response.varfile

RUN set -e && \
    export KEYSTORE=$JAVA_HOME/lib/security/cacerts && \
    wget -q -P /tmp/ https://letsencrypt.org/certs/letsencryptauthorityx1.der && \
    wget -q -P /tmp/ https://letsencrypt.org/certs/letsencryptauthorityx2.der && \
    wget -q -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.der && \
    wget -q -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x2-cross-signed.der && \
    wget -q -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.der && \
    wget -q -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x4-cross-signed.der && \
    keytool -trustcacerts -keystore ${KEYSTORE} -storepass changeit -noprompt -importcert -alias isrgrootx1 -file /tmp/letsencryptauthorityx1.der && \
    keytool -trustcacerts -keystore ${KEYSTORE} -storepass changeit -noprompt -importcert -alias isrgrootx2 -file /tmp/letsencryptauthorityx2.der && \
    keytool -trustcacerts -keystore ${KEYSTORE} -storepass changeit -noprompt -importcert -alias letsencryptauthorityx1 -file /tmp/lets-encrypt-x1-cross-signed.der && \
    keytool -trustcacerts -keystore ${KEYSTORE} -storepass changeit -noprompt -importcert -alias letsencryptauthorityx2 -file /tmp/lets-encrypt-x2-cross-signed.der && \
    keytool -trustcacerts -keystore ${KEYSTORE} -storepass changeit -noprompt -importcert -alias letsencryptauthorityx3 -file /tmp/lets-encrypt-x3-cross-signed.der && \
    keytool -trustcacerts -keystore ${KEYSTORE} -storepass changeit -noprompt -importcert -alias letsencryptauthorityx4 -file /tmp/lets-encrypt-x4-cross-signed.der && \
    wget -O /SSLPoke.class https://confluence.atlassian.com/kb/files/779355358/779355357/1/1441897666313/SSLPoke.class

RUN wget -O /tmp/dockerize.tar.gz https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf /tmp/dockerize.tar.gz && \
    rm /tmp/dockerize.tar.gz

RUN set -e && \
    export CONTAINER_USER=$RUN_USER && \
    export CONTAINER_GROUP=$RUN_GROUP &&  \
    addgroup -g ${RUN_GID} ${RUN_GROUP} && \
    adduser -u ${RUN_UID} \
            -G ${RUN_GROUP} \
            -h ${JIRA_HOME} \
            -s /bin/false \
            -S ${RUN_USER}

RUN set -e && \
    rm -f ${JIRA_INSTALL}/lib/mysql-connector-java*.jar && \
    curl -Ls "${JVM_MYSQL_CONNECTOR_URL}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz" | tar -xz --strip-components=1 -C "/tmp" && \
    cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar ${JIRA_INSTALL}/lib/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar && \
    chown -R ${RUN_USER}:${RUN_GROUP} ${JIRA_HOME} ${JIRA_INSTALL} ${JIRA_SCRIPTS}  && \
    chmod -R 774 ${JIRA_HOME}/.. ${JIRA_INSTALL} ${JIRA_SCRIPTS} && \
    chown -R root:${RUN_GROUP} /opt/jdk* && \
    apk del ca-certificates wget curl unzip tzdata && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* /opt/jdk*.gz

# --
# define container execution behaviour
# --

USER ${RUN_USER}

VOLUME ["${JIRA_HOME}"]

WORKDIR ${JIRA_HOME}

EXPOSE 8080

ENTRYPOINT ["/sbin/tini","--","/usr/local/share/atlassian/entrypoint.sh"]

CMD ["jira"]
