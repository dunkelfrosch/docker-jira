# ChangeLog of DockerJira 7.13.0

All notable changes of the DockerJira release series are documented in this file using the [Keep a CHANGELOG](http://keepachangelog.com/) principles.

_This DockerJira changeLog documentation start with version 0.9.6 (2015-12-26)_


## [1.0.6], 2018-12-01
_current_

### Changes
- upgrade jira to version 7.13.0

## [1.0.5], 2018-07-01

### Changes
- upgrade jira to version 7.10.2

## [1.0.4], 2018-04-17

### Changes
- upgrade jira to version 7.9.1
- refactor dockerfile structure
- minor changes in documentation


## [1.0.3], 2018-04-17

### Changes
- upgrade jira to version 7.9 (7.9.0)
- switch to new alpine jdk8 base image
- massive refactoring of core docker image

### Added
- new crowd trusted keystore ssl (letsencrypt)


## [1.0.2], 2017-07-08

### Changes
- upgrade jira to version 7.4 (7.4.0)


## [1.0.1], 2017-01-21

### Changes
- upgrade jira to latest version 7.3 (7.3.0)
- add new service version label


## [1.0.0], 2016-07-08:

### Changes
- upgrade jira to latest version 7.1 (7.1.9)

## [0.9.9], 2016-02-20:

### Added
- new sample files for docker compose format v2 (1.6.n)
- new mysql config to provide utf8 compatibility for jira
- travis ci command, remove latest image build

### Changes
- upgrade jira to latest version 7.1 (7.1.2)
- minor issues in docker-compose file definition
- default password for sample db config

### Fixed
- fix documentation issue in docker-compose sample files
- fix minor changelog issues


## [0.9.8], 2015-12-29:

### Changes
fix namespace issues (prepare docker hub integration)
minor documentation issues


## [0.9.7], 2015-12-27:

### Changes
extend main documentation
improve code documentation

### Added
docker-compose sample yaml files
travis build test


## [0.9.6], 2015-12-26:

### Added
initial commit
