# Docker Image for Atlassian JIRA 7.0.5

*this documentation isn't finally done yet - we still working on major and minor issues corresponding to this repository base!*

this repository provide the currently latest version of Atlassians version control software [jira server](https://de.atlassian.com/software/jira) including the recommended [MySQL java connector](http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.36.tar.gz) for an easy and painless docker based jira installation. Take note, that this repository will be used inside our docker atlassian application workbench sources (also available on Github as soon as our documentation stands stable and "readable"). *In this workbench we've combine additional atlassian products (jira, confluence and jira) using advanced docker features like docker-compose based service management, data-container, links* …

[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![System Version](https://img.shields.io/badge/version-0.9.6%20alpha-red.svg)](VERSION)
[![System State](https://img.shields.io/badge/state-initial%20build-red.svg)](STATE)

## Preparation
we recommended the usage of the latest version docker and for simple system integration/supervision docker's "in-house" application docker-compose.
If you're using MacOS or Windows as host operating system, you may take the advantage of docker-machine for docker's vm management. Bitbucket needs
a relational database like MySQL or PostgreSQL linked to. We'll provide a spec.
MySQL container configuration inside this documentation beside a docker-compose sample yaml config file, to show container linking feature. Use the installation guides of provided links down below to comply your docker pre-peration process.

[docker installation guide](https://docs.docker.com/engine/installation/)</br>
[docker-compose installation guide](https://docs.docker.com/compose/install/)</br>
[docker machine installation guide](https://docs.docker.com/machine/install-machine/)</br>

## Installation, Method 1
this steps will show you the generic, pure docker based installation of our jira image container, without any database container linked or data-container feature.  *We also will provide a docker-compose based installation in this documentation*.

1. checkout this repository

2. build jira (version 7.0.5) image on your local docker host

```bash
docker build -t df/jira:7.0.5
```

3. start your new jira application container

```bash
docker run -d -p 7990:7990 df/jira 
```
	
4. finish your installation using atlassian's browser based configuration 
just navigate to `http://[dockerhost]:8080` 

## Contribute

DFDockerJira is still under development and contributors are always welcome! Feel free to join our docker-jira distributor team. Please refer to [CONTRIBUTING.md](https://github.com/dunkelfrosch/dfdockerjira/blob/master/CONTRIBUTING.md) and find out how to contribute to this Project.


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