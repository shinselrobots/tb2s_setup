# tb2s 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Build Status](https://travis-ci.org/shinselrobots/tb2s_setup.svg?branch=master)](https://travis-ci.org/shinselrobots/tb2s_setup)

This repository contains installation scripts that are used to quickly configure the tb2s robot computer with files required for development.

## Prerequisites

The script assumes the computer is connected to the public internet, has Ubuntu 16.04 installed, and that the user has sudo permissions.  The script will ask for your sudo password at the beginning of the script, and will drop those permissions as soon as possible and perform the bulk of the installation with your normal user permissions.

## Installation instructions

```bash
$ wget --output-document script_setup.sh https://raw.githubusercontent.com/shinselrobots/tb2s_setup/master/script_setup.sh 
$ bash ./script_setup.sh
```

## Updating source from previous installation

```bash
$ cd ~/catkin_robot
$ wstool update -t src
```

## Building 

While developing, use the following command to build new code being developed:
```bash
$ cd ~/catkin_robot
$  catkin_make
```
