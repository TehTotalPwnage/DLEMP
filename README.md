# DLEMP
**Work in progress. Caution is advised.**

DLEMP (an abbreviation for Docker Linux Nginx MySQL PHP) is a shell program designed to make the deployment of LEMP stack applications in a Docker container much easier.

To do this, an interactive terminal program and a few other commands are provided in order to reduce the effort needed to deploy an application. Rather than type out numerous Docker commands or find multiple Docker images to put together, this application bundles all of the necessary configuration files, Dockerfiles, and other resources together. As a result, the only thing needed is to run `DLEMP.sh` in a terminal to get started.

## Usage

**Note: This script has been designed for Ubuntu 16.04.
Other Linux distributions remain untested.**

The entrypoint to the application is DLEMP.sh:
```
tehtotalpwnage@tehtotalpwnage:~/git/DLEMP$ ./DLEMP.sh

The Docker LEMP Container Management Program (DLEMP)
Created by Michael Nguyen (TehTotalPwnage)
Actions
-------
1) Build Docker Image
2) Deploy Docker Container
3) Deploy Development Environment
4) Save Build Configuration
5) Install Package Dependencies
6) Exit
```

1. **Build Docker Image** - This builds a Docker image based off a given GitHub repository to clone.
2. **Deploy Docker Container** - Once an image has been built, this command can be run in order to put the image into an actual container for deployment.
3. **Deploy Development Environment** - This mounts a folder on your host as a volume of a container for the purposes of a development environment.
4. **Save Build Configuration** - Will be removed in the future.
5. **Install Package Dependencies** - Installs the dependencies needed to run this application using APT, such as the Docker Engine.

Two other commands can be run noninteractively:
```
# Opens a bash shell on the container for troubleshooting.
DLEMP.sh bash <container name>

# Copies a file to the host for editing, before copying it back.
DLEMP.sh cp <container name>:<path to file>
```

## Installation
Clone this repository on any system in order to download the DLEMP.sh script as well as all of the required configuration files:
```
git clone git@github.com:TehTotalPwnage/DLEMP.git
```

## License
Copyright 2017 Michael Nguyen

This file is part of DLEMP.

DLEMP is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

DLEMP is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with DLEMP. If not, see http://www.gnu.org/licenses/.
