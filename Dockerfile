#
# BUILD    : DF/[ATLASSIAN][JIRA]
# OS/CORE  : java:8
# SERVICES : -
#
# VERSION 0.9.7
#

FROM java:8

MAINTAINER Patrick Paechnatz <patrick.paechnatz@gmail.com>
LABEL com.container.vendor="dunkelfrosch impersonate" \
      com.container.service="atlassian/jira" \
      com.container.priority="1" \
      com.container.project="jira" \
      img.version="0.9.7" \
      img.description="atlassian jira application container"

# Setup base environment variables
ENV TERM                    xterm
ENV LC_ALL                  C.UTF-8
ENV DEBIAN_FRONTEND         noninteractive
ENV TIMEZONE                "Europe/Berlin"

# Setup application install environment variables
ENV JIRA_VERSION            7.0.5
ENV JIRA_HOME               "/var/atlassian/jira"
ENV JIRA_INSTALL            "/opt/atlassian/jira"
ENV DOWNLOAD_URL            "https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-core-"
ENV JVM_MYSQL_CONNECTOR_URL "http://dev.mysql.com/get/Downloads/Connector-J"
ENV JVM_MYSQL_CONNETOR      "mysql-connector-java-5.1.36"
ENV JAVA_HOME               "/usr/lib/jvm/java-1.8.0-openjdk-amd64"
ENV RUN_USER                daemon
ENV RUN_GROUP               daemon

# x-layer 1: package manager related processor
RUN apt-get update -qq \
    && apt-get install -qq -y --no-install-recommends git liblucene2-java mc xmlstarlet ntp \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/cache /var/lib/log /tmp/* /var/tmp/*

# x-layer 2: application base setup related processor
RUN mkdir -p ${JIRA_HOME}/lib \
             ${JIRA_HOME}/caches/indexes \
             ${JIRA_INSTALL}/conf/Catalina \
             ${JIRA_INSTALL}/lib \

    && curl -Ls "${DOWNLOAD_URL}${JIRA_VERSION}.tar.gz" | tar -xz --directory "${JIRA_INSTALL}" --strip=1 \
    && curl -Ls "${JVM_MYSQL_CONNECTOR_URL}/${JVM_MYSQL_CONNETOR}.tar.gz" | tar -xz --directory "${JIRA_INSTALL}/lib" --strip=1 --no-same-owner "${JVM_MYSQL_CONNETOR}/${JVM_MYSQL_CONNETOR}-bin.jar" \
    && sed --in-place "s/java version/openjdk version/g" "${JIRA_INSTALL}/bin/check-java.sh" \
    && echo -e "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties" \
    && chmod -R 700 ${JIRA_HOME} ${JIRA_INSTALL} \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${JIRA_HOME} ${JIRA_INSTALL}

# x-layer 3: application advanced setup related processor
RUN echo "${TIMEZONE}" >/etc/timezone \
    && dpkg-reconfigure tzdata >/dev/null 2>&1

#
# -> if you're running this jira container outside a workbench scenario, you
#    can activate VOLUME feature ...
#
# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory (accessing logs). These directories will be set-and-used during
# data-only container volume bound run-mode.
# VOLUME ["${JIRA_INSTALL}", "${JIRA_HOME}"]

# Expose default HTTP connector port.
EXPOSE 8080

# Next, set the default working directory as jira home directory.
WORKDIR ${JIRA_INSTALL}

# Set base container execution user/group (no root-right container allowed here)
# using the default unprivileged account.
USER ${RUN_USER}:${RUN_GROUP}

# Set entrypoint script for application, jira will run as foreground process (-fg)
CMD ["/opt/atlassian/jira/bin/start-jira.sh", "-fg"]