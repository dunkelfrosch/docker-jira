# Docker Image for Atlassian JIRA 7.0.5

*this documentation isn't fully done yet - we're still working on major and minor issues corresponding to this repository base!*

This repository provides the latest version of Atlassians agile/ticket [JIRA](https://de.atlassian.com/software/jira) software including the recommended [MySQL java connector](http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.36.tar.gz) for an easy and painless docker based JIRA installation. Take note that this repository will be used inside our docker atlassian application workbench sources, which are also available on Github as soon as documentation is completed. *In this workbench we've combined several Atlassian products (JIRA, Confluence and Bitbucket) using advanced docker features like docker-compose based service management, data-container and links*

[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![System Version](https://img.shields.io/badge/version-0.9.7-blue.svg)](VERSION)
[![Build Status](https://Ftravis-ci.org/dunkelfrosch/docker-jira.svg?branch=master)](https://travis-ci.org/dunkelfrosch/docker-jira)

## Preparation
We recommend the [latest Docker version](https://github.com/docker/docker/blob/master/CHANGELOG.md).  For simple system integration and supervision we suggest [Docker Compose](https://docs.docker.com/compose/install/). If you're using MacOS or Windows as host operating system, you may take the advantage of [Docker Machine](https://www.docker.com/docker-machine) for Docker's VM management. JIRA requires a relational database like MySQL or PostgreSQL, so we'll provide a specific Docker Compose configuration file to showcase both a JIRA-MySQL link and a data-container feature configuration. Use the installation guides of provided links down below to comply your Docker preparation process.

[docker installation guide](https://docs.docker.com/engine/installation/)</br>
[docker-compose installation guide](https://docs.docker.com/compose/install/)</br>
[docker machine installation guide](https://docs.docker.com/machine/install-machine/)</br>


## Installation-Method 1, the classic Docker way
As long as our image isn't available via docker.io hub repository, you will need to build it by yourself using this Github repository. These steps will show you the generic, pure Docker based installation of our JIRA image container, without any database container linked or data-container feature.  *We also will provide a Docker Compose based installation in this documentation (Method 2)*.

1) checkout this repository

```bash
git clone https://github.com/dunkelfrosch/docker-jira.git .
```

2) build jira (version 7.0.5) image on your local docker host, naming image "dunkelfrosch/jira:7.0.5"

```bash
docker build -t dunkelfrosch/jira:7.0.5
```

3) start your new jira application container

```bash
docker run -d -p 8080:8080 dunkelfrosch/jira 
```
	
4) finish your installation using atlassian's browser based configuration 
just navigate to `http://[dockerhost]:8080` 


## Installation-Method 2, via Docker Compose (simple)
The following steps will show you an alternative way of your JIRA service container installation using Docker Compose

1) checkout this repository

```bash
git clone https://github.com/dunkelfrosch/docker-jira.git .
```
 
2) create a docker-compose.yml file in your target directory (or use the existing one), afterwards insert the following lines (docker-compose.yml in *./sample-configs/* directory). 

![](https://dl.dropbox.com/s/t31n8ckncv09np9/dc_setup_001.png)

3) start your JIRA container by docker-compose

```bash
docker-compose up -d jira
```

4) (*optional*) rename the resulting image after successful build (we'll use our image auto-name result here)

```bash
docker tag dfdockerjira_jira dunkelfrosch/jira:7.0.5
```

5) the result should by a running container and an available local JIRA image

![](https://dl.dropbox.com/s/oqwy8wquey5rjkh/dc_result_001.png)


## Installation-Method 3, docker-compose (using db)
JIRA needs a relational DB and for safety reasons we suggest using data-only container features. Take a look inside your *./sample-config* path, we've provided a few sample Docker Compose yaml config files below to show you those feature implementations.

./sample-configs/**docker-compose-dc.yml**
> sample configuration for data-container feature

./sample-configs/**docker-compose-linkdb.yml**
> sample configuration for linking mysql container directly


## container access and maintenance
You can check container health by accessing logs of inner Tomcat/JIRA processes directly as long as the container is still running. As you can see in this screenshot, Atlassian JIRA was starting successfully (*Let's ignore some minor warnings ;)* )

```bash
docker logs df-atls-jira
```

![](https://dl.dropbox.com/s/6yll5ohrzv96iz8/dc_logs_001.png)

You can log in easily to your running JIRA container to take a deeper look in your JIRA service process. *This JIRA build provides midnight-commander as terminal extension accessible typing `mc` in your container session shell*.

```bash
docker exec -it --user root df-atls-jira /bin/bash
```

![](https://dl.dropbox.com/s/sp9zfzoqhw9pc2y/dc_term_001.png)


## Contribute

Docker JIRA is still under development and contributors are always welcome! Feel free to join our docker-jira distributor team. Please refer to [CONTRIBUTING.md](https://github.com/dunkelfrosch/docker-jira/blob/master/CONTRIBUTING.md) and find out how to contribute to this Project.


## License-Term

Copyright (c) 2015 Patrick Paechnatz <patrick.paechnatz@gmail.com>
                                                                           
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