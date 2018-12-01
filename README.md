# Docker Image for Atlassian JIRA

This repository provides the latest version of Atlassians agile/ticket [JIRA](https://de.atlassian.com/software/jira) software including the recommended [MySQL java connector](http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.36.tar.gz) for an easy and painless docker based JIRA installation. Take note that this repository will be used inside our docker atlassian application workbench sources, which are also available on [Github](https://github.com/dunkelfrosch/docker-atlassian-wb) as soon as documentation is completed. *In this workbench we've combined several Atlassian products (JIRA, Confluence and Bitbucket) using advanced docker features like docker-compose based service management, data-container and links*

[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![System Version](https://img.shields.io/badge/version-1.0.6-blue.svg)](VERSION1)
[![JIRA Version](https://img.shields.io/badge/jira-7.13.0-blue.svg)](VERSION2)
[![Build Status](https://api.travis-ci.org/dunkelfrosch/docker-jira.svg?branch=master)](https://travis-ci.org/dunkelfrosch/docker-jira)


## Preparation
We recommend the [latest Docker version](https://github.com/docker/docker/blob/master/CHANGELOG.md).  For simple system integration and supervision we suggest [Docker Compose](https://docs.docker.com/compose/install/). If you're using MacOS or Windows as host operating system, you may take the advantage of [Docker Machine](https://www.docker.com/docker-machine) for Docker's VM management. JIRA requires a relational database like MySQL or PostgreSQL, so we'll provide a specific Docker Compose configuration file to showcase both a JIRA-MySQL link and a data-container feature configuration. Use the installation guides of provided links down below to comply your Docker preparation process.

[docker installation guide](https://docs.docker.com/engine/installation/)</br>
[docker-compose installation guide](https://docs.docker.com/compose/install/)</br>
[docker-machine installation guide](https://docs.docker.com/machine/install-machine/)</br>


## Installation-Method 1, using docker
These steps will show you the generic, pure docker-based installation of Atlassian JIRA image/container, without any database container linked or data-container feature.  *We also will provide (and recommend) a docker-compose based installation in this documentation (↗ Installation-Method 2)*.

1) checkout this repository

```bash
git clone https://github.com/dunkelfrosch/docker-jira.git .
```

2.1) build your JIRA image (version 7.10.2) on your local docker host, naming image "dunkelfrosch/jira:7.10.2" (or 'latest')

```bash
docker build -t dunkelfrosch/jira:latest
```

2.2) pull our compiled JIRA image from docker-hub directly by activating the corresponding lines in our docker-compose.yml file

3) start your new jira application container

```bash
docker run -d -p 8080:8080 dunkelfrosch/jira 
```
	
4. finish your installation using atlassian's browser based configuration
just navigate to `http://[dockerhost]:8080`. Please take note, that your dockerhost will depend on your host system. If you're using docker on your mac, you'll properly using docker-machine or the deprecated native boot2docker vbox image. In this case your 'dockerhost' ip will be the vbox ones (just enter `docker-machine ls` and grab your named machine's ip from there. In my case (image down below) the resulting setup-ip will be <strong>192.168.99.100:8080</strong> on any other "real" linux system the setup-ip should be 127.0.0.1/localhost (port will be the tomcat application used port 8080)

![](https://dl.dropbox.com/s/jnmr3ejkzm12hdc/dm_start_003.png)

4.1 The following steps will help you to finalize your bitbucket server web-based configuration

4.1.1 Select "I'll set it up myself" and click <strong>Continue to MyAtlassian</strong>

![](https://dl.dropbox.com/s/rarhgz5h7czs6aj/jira_setup_001.png)

4.1.2 Select "My own Database", choose MySQL as type and enter the following credentials for your database (take note, that the mysql host will be available as your in docker-compose defined service key 'bitbucket_mysql' or by container-name 'df-atls-bitbucket-mysql' directly):
_the initialization and base import of the db will take a while (may be up to 5 minutes)_

![](https://dl.dropbox.com/s/ia50o9dpx15pa60/jira_setup_002.png)

| MySQL Host         | username                   | password            | database            |
|:------------------ |:-------------------------- |:------------------- |:------------------- |
| df-atls-jira-mysql | root                       | please-change-me    | jira                |
| (or) jira_mysql    |                            |                     |                     |

4.1.3 Enter the name, mode and base url of your JIRA server

![](https://dl.dropbox.com/s/h3j4y4kx4q50gs8/jira_setup_005.png)

4.1.4 Enter your license key

![](https://dl.dropbox.com/s/4a50xof596vfkbq/jira_setup_006.png)

4.1.5 Create your JIRA administrator user account 
      
![](https://dl.dropbox.com/s/4j4pealytpoyr1m/jira_setup_007.png)

4.1.5 Skip mail notification setup, select language code and your avatar

4.1.6 Jump through introduction screens and (optional) create your 1st JIRA project

4.1.7 Install/initialize JIRA Software by clicking "Applications" in the upper right administration menu

![](https://dl.dropbox.com/s/lxx3u2hengnbxeq/jira_setup_015_02.png)

4.1.8 Update plugins (if required) by clicking the notification icon and corresponding link in the upper left of top-bar

![](https://dl.dropbox.com/s/glsplt1bw0dclyu/jira_setup_015_03.png)

4.1.9 Welcome to JIRA

![](https://dl.dropbox.com/s/b3zixmasbldfbgc/jira_setup_014.png)


## Installation-Method 2, via Docker Compose (simple)
The following steps will show you an alternative way of your JIRA service container installation using Docker Compose

1) checkout this repository

```bash
git clone https://github.com/dunkelfrosch/docker-jira.git .
```
 
2.1) create/use a docker-compose.yml file in your target directory (or use the existing one), afterwards insert the following lines (docker-compose.yml in *./sample-configs/* directory). 

![](https://dl.dropbox.com/s/u75cn8rj21ad27o/jira_dc_image_mode_002.png)

2.2) you can also pull our compiled JIRA image from docker-hub directly by activating the corresponding lines in our docker-compose.yml file

![](https://dl.dropbox.com/s/3zpl852vltwgy2l/jira_dc_image_mode_001.png)

3) start your JIRA container by docker-compose

```bash
docker-compose up -d jira
```

4) (*optional*) rename the resulting image after successful build (we'll use our image auto-name result here)

```bash
docker tag dfdockerjira_jira dunkelfrosch/jira:latest
```

5) the result should by a running container and an available local JIRA image

![](https://dl.dropbox.com/s/zeinhgunlpv7v74/jira_image_list_001.png)
![](https://dl.dropbox.com/s/6iz03kzz4l0iubh/jira_container_list_001.png)


## Installation-Method 3, docker-compose (using db)
JIRA needs a relational DB and for safety reasons we suggest using data-only container features. Take a look inside your *./sample-config* path, we've provided a few sample Docker Compose yaml config files below to show you those feature implementations.

./sample-configs/**docker-compose-dc.yml**
> sample configuration for data-container feature

./sample-configs/**docker-compose-linkdb.yml**
> sample configuration for linking mysql container directly

./sample-configs/**docker-compose-dc-v2.yml**
> new docker compose formatted sample configuration for data-container feature

./sample-configs/**docker-compose-linkdb-v2.yml**
> new docker compose formatted sample configuration for linking mysql container directly

./sample-configs/**docker-compose-netdb-v2.yml**
> sample configuration for new networking feature connected mysql/jira container


## container access and maintenance
You can check container health by accessing logs of inner Tomcat/JIRA processes directly as long as the container is still running. As you can see in this screenshot, Atlassian JIRA was starting successfully (*Let's ignore some minor warnings ;)* )

```bash
docker logs df-atls-jira
```

![](https://dl.dropbox.com/s/p146oopnfs9rjpi/jira_log_001.png)

You can log in easily to your running JIRA container to take a deeper look in your JIRA service process. *This JIRA build provides midnight-commander as terminal extension accessible typing `mc` in your container session shell*.

```bash
docker exec -it --user root df-atls-jira /bin/bash
```

![](https://dl.dropbox.com/s/sp9zfzoqhw9pc2y/dc_term_001.png)


## Contribute

This project is still under development and contributors are always welcome! Please refer to [CONTRIBUTING.md](https://github.com/dunkelfrosch/docker-jira/blob/master/CONTRIBUTING.md) and find out how to contribute to this project.


## License-Term

Copyright (c) 2015-2018 Patrick Paechnatz <patrick.paechnatz@gmail.com>
                                                                           
Permission is hereby granted,  free of charge,  to any  person obtaining a 
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction,  including without limitation
the rights to use,  copy, modify, merge, publish,  distribute, sublicense,
and/or sell copies  of the  Software,  and to permit  persons to whom  the
Software is furnished to do so, subject to the following conditions:       
                                                                           
The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.
                                                                           
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING  BUT NOT  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR  PURPOSE AND  NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,  WHETHER IN AN ACTION OF CONTRACT,  TORT OR OTHERWISE,  ARISING
FROM,  OUT OF  OR IN CONNECTION  WITH THE  SOFTWARE  OR THE  USE OR  OTHER DEALINGS IN THE SOFTWARE.