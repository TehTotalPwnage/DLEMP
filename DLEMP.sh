#!/bin/bash

# Copyright 2017 Michael Nguyen
#
# This file is part of DLEMP.
#
# DLEMP is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# DLEMP is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with DLEMP. If not, see http://www.gnu.org/licenses/.

function menu {
    if [[ $# -eq 0 ]]; then
        clear
        echo "The Docker LEMP Container Management Program (DLEMP)"
        echo "Created by Michael Nguyen (TehTotalPwnage)"
        echo "Actions"
        echo "-------"
        echo "1) Build Docker Image"
        echo "2) Deploy Docker Container"
        echo "3) Deploy Development Environment"
        echo "4) Save Build Configuration"
        echo "5) Install Package Dependencies"
        echo "6) Exit"
        read -n 1 input
    fi
    case "$1$input" in
        1)
            echo "Building Docker image..."
            echo "Which Git repo would you like to clone onto the image?"
            echo "Give your response in the form of USERNAME/REPOSITORY (ex. TehTotalPwnage/DLEMP)"
            read repo
            git clone "git@github.com:$repo" repo
            tag=${repo:`expr index "$repo" /`:256}
            docker build --no-cache -t=${tag,,} .
            if [ $? != 0 ]; then
                echo "Error on Docker image build..."
            else
                echo "Docker image built successfully!"
            fi
            rm -rf repo
            pause
            ;;
        2)
            echo "Deploying Docker container..."
            echo "Which image do you want to base the container off of?"
            read image
            echo "Which external port do you want to bind to the container?"
            read port
            echo "Do you want to link a development volume to the container? Leave blank or provide a path:"
            read volume
            if [ -n "$volume" ]; then
                echo "Should this container boot to the development environment setup by default? 1) Yes 2) No"
                read startup
                if [ $startup == 1 ]; then
                    docker create --name "${image}_lemp" --publish $port:80 --volume $volume:/srv/mnt $image start dev
                else
                    docker create --name "${image}_lemp" --publish $port:80 --volume $volume:/srv/mnt $image
                fi
            else
                docker create --name "${image}_lemp" --publish $port:80 $image
            fi
            if [ $? != 0 ]; then
                echo "Error on Docker container deployment..."
            else
                echo "Docker container deployed successfully!"
            fi
            pause
            ;;
        3)
            echo "Deploying development environment..."
            echo "What is the absolute path to the development directory? (ex. /home/tehtotalpwnage/git/DLEMP)"
            read path
            # tag=${path:`expr index "$path" /`:256}
            tag=${path##/*/}
            docker build -f "$(dirname $0)/dockerfiles/dev-dockerfile" -t=${tag,,} "$(dirname $0)"
            echo "Deploying Docker container..."
            echo "Which external port do you want to bind to the container?"
            read port
            docker create --name "${tag,,}_dev" --publish $port:80 --volume $path:/srv/mnt ${tag,,}
            if [ $? != 0 ]; then
                echo "Error on development container deployment..."
            else
                echo "Development container deployed successfully!"
            fi
            pause
            ;;
        4)
            echo "Which Git repo do you want to use for the server image builds?"
            echo "Give your response in the form of USERNAME/REPOSITORY (ex. TehTotalPwnage/DLEMP)"
            read repo
            ;;
        5)
            echo "Installing dependencies..."
            echo "Updating repositories..."
            echo "Installing additional kernel storage drivers for Docker..."
            sudo apt-get install linux-image-extra-"$(uname -r)" linux-image-extra-virtual
            echo "Preparing repository dependencies..."
            sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
            echo "Adding GPG key for Docker repository..."
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            echo "Printing key, please verify that the fingerprint is as follows:"
            echo "9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88"
            sudo apt-key fingerprint 0EBFCD88
            echo "If the key matches, type Y. If not, type n. (Y/n)"
            read -n 1 match
            case "$match" in
                "Y")
                    ;&
                "y")
                    echo "Adding APT repository for Docker..."
                    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
                    echo "Reloading package index..."
                    sudo apt-get update
                    echo "Installing Docker..."
                    sudo apt-get install docker-ce
                    echo "Testing Docker installation..."
                    sudo docker run hello-world
                    echo "Now running postinstallation steps..."
                    echo "Adding nonroot access permissions..."
                    sudo groupadd docker
                    sudo usermod -aG docker $USER
                    echo "Configuring Docker to run at boot..."
                    sudo systemctl enable docker
                    echo "Complete! Please relog into the system to save your changes..."
                    ;;
                *)
                    echo "Fingerprint doesn't match. Terminating to prevent security concerns."
                    ;;
            esac
            pause
            ;;
        6)
            echo "Now exiting..."
            echo "If you like this project, please star it on GitHub: https://github.com/TehTotalPwnage/DLEMP"
            echo "If you'd like to support me, consider donating on Patreon: https://patreon.com/tehtotalpwnage"
            pause
            exit 0
            ;;
        *)
            echo "Unrecognized command. Please enter another command."
            pause
            ;;
    esac
}

function pause {
    echo "Press any key to continue..."
    read -n 1
}

case "$1" in
    "cp")
        mkdir -p /tmp/dlemp
        docker cp "$2" /tmp/dlemp/tmpcp
        editor /tmp/dlemp/tmpcp
        docker cp /tmp/dlemp/tmpcp "$2"
        ;;
    "bash")
        docker exec -it "$2" /bin/bash
        ;;
    *)
        while true; do
            menu
        done
        ;;
esac
