#
# BUILD    : DF/[ATLASSIAN][JIRA]
# OS/CORE  : blacklabelops/alpine:3.7
# SERVICES : ntp, ...
#
# VERSION 1.0.5
#

FROM blacklabelops/alpine:3.7

MAINTAINER Patrick Paechnatz <patrick.paechnatz@gmail.com>
LABEL com.container.vendor="dunkelfrosch impersonate" \
      com.container.service="atlassian/jira" \
      com.container.service.verion="7.9.1" \
      com.container.priority="1" \
      com.container.project="jira" \
      img.version="1.0.5" \
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
    MYSQL_CONNECTOR_URL="http://dev.mysql.com/get/Downloads/Connector-J" \
    DOWNLOAD_URL="https://www.atlassian.com/software/jira/downloads/binary"

ENV JAVA_HOME=${JIRA_INSTALL}/jre
ENV PATH=$PATH:${JAVA_HOME}/bin \
    LANG=${ISO_LANGUAGE}_${ISO_COUNTRY}.UTF-8

COPY scripts/* ${JIRA_SCRIPTS}/

# prepare directories
RUN mkdir -p ${JIRA_HOME}/caches/indexes \
             ${JIRA_INSTALL}/conf/Catalina \
             ${JIRA_INSTALL}/lib

# install glibc using origin sources
RUN apk add --update ca-certificates mc gzip curl tar xmlstarlet wget tzdata bash tini && \
    export GLIBC_VERSION=2.26-r0 && \
    wget -q --directory-prefix=/tmp https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    wget -q --directory-prefix=/tmp https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
    wget -q --directory-prefix=/tmp https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk && \
    apk add --allow-untrusted /tmp/glibc-${GLIBC_VERSION}.apk && \
    apk add --allow-untrusted /tmp/glibc-bin-${GLIBC_VERSION}.apk && \
    apk add --allow-untrusted /tmp/glibc-i18n-${GLIBC_VERSION}.apk && \
    /usr/glibc-compat/bin/localedef -i ${ISO_LANGUAGE}_${ISO_COUNTRY} -f UTF-8 ${ISO_LANGUAGE}_${ISO_COUNTRY}.UTF-8 && \
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" >/etc/timezone

# install jira using origin atlassian (bin) installer
RUN export JIRA_BIN=atlassian-${JIRA_PRODUCT}-${JIRA_VERSION}-x64.bin && \
    wget -q -P /tmp/ https://www.atlassian.com/software/jira/downloads/binary/${JIRA_BIN} && \
    mv /tmp/${JIRA_BIN} /tmp/jira.bin && \
    chmod +x /tmp/jira.bin && /tmp/jira.bin -q -varfile ${JIRA_SCRIPTS}/response.varfile

# install mysql connector (using java-origin tar.gz)
RUN export MYSQL_CONNECTOR=mysql-connector-java-${MYSQL_CONNECTOR_VERSION:-5.1.36} && \
    export MYSQL_CONNECTOR_TAR=${MYSQL_CONNECTOR}.tar.gz && \
    export MYSQL_CONNECTOR_BIN=${MYSQL_CONNECTOR}-bin.jar && \
    rm -f ${JIRA_INSTALL}/lib/mysql-connector-java*.jar && \
    wget -q -O /tmp/${MYSQL_CONNECTOR_TAR} ${MYSQL_CONNECTOR_URL}/${MYSQL_CONNECTOR_TAR} && \
    tar xzf /tmp/${MYSQL_CONNECTOR_TAR} --directory=/tmp && \
    mv /tmp/${MYSQL_CONNECTOR}/${MYSQL_CONNECTOR_BIN} ${JIRA_INSTALL}/lib/${MYSQL_CONNECTOR_BIN}

# install service user
RUN export CONTAINER_USER=jira &&  \
    export CONTAINER_UID=1000 &&  \
    export CONTAINER_GROUP=jira &&  \
    export CONTAINER_GID=1000 &&  \
    addgroup -g ${CONTAINER_GID} ${CONTAINER_GROUP} && \
    adduser -u ${CONTAINER_UID} \
            -G ${CONTAINER_GROUP} \
            -h /home/${CONTAINER_USER} \
            -s /bin/bash \
            -S ${CONTAINER_USER}

# install/setup keystore using host based letsencrypt CA (for growd sso)
RUN export KEYSTORE=${JAVA_HOME}/lib/security/cacerts && \
    wget -q -O /SSLPoke.class https://confluence.atlassian.com/kb/files/779355358/779355357/1/1441897666313/SSLPoke.class && \
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
    keytool -trustcacerts -keystore ${KEYSTORE} -storepass changeit -noprompt -importcert -alias letsencryptauthorityx4 -file /tmp/lets-encrypt-x4-cross-signed.der

# install (upgrade) new dockerized toolbox
RUN wget -q -O /tmp/dockerize.tar.gz https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf /tmp/dockerize.tar.gz

# chown/chmod/cleanUp
RUN chown -R ${JIRA_USER}:${JIRA_GROUP} ${JIRA_HOME} ${JIRA_INSTALL} ${JIRA_SCRIPTS} /home/${JIRA_USER} && \
    apk del ca-certificates wget curl unzip tzdata && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

# --
# define container execution behaviour
# --

USER ${RUN_USER}

VOLUME ["${JIRA_HOME}"]

WORKDIR ${JIRA_HOME}

EXPOSE 8080

ENTRYPOINT ["/sbin/tini","--","/usr/local/share/atlassian/entrypoint.sh"]

CMD ["jira"]
