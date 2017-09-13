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

BUILD_CMD=(docker build)
CACHE_UPDATE=false

# Since ln requires absolute pathnames as a pointer, we store the working directory as a variable.
WORKING_DIR="$(dirname "$(readlink -f "$0")")"

function args {
    case "$1" in
        "-n" | "--no-cache")
            echo "Running with cache ignored on builds..."
            BUILD_CMD+=("--no-cache")
            sleep 2
            while true; do
                menu
            done
            ;;
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
}

function cache {
    echo "Cache is outdated. Running with --no-cache enabled..."
    BUILD_CMD+=("--no-cache")
    CACHE_UPDATE=true
    sleep 2
}

function menu {
    cd "$(dirname "$(readlink -f "$0")")"
    if [[ $# -eq 0 ]]; then
        clear
        echo "The Docker LEMP Container Management Program (DLEMP)"
        echo "Created by Michael Nguyen (TehTotalPwnage)"
        echo "Actions"
        echo "-------"
        echo "1) Build Docker Image"
        echo "2) Deploy Docker Compose Stack"
        echo "3) Deploy Development Environment"
        echo "4) Manage Build Configurations"
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
            tag=${repo:`expr index "$repo" /`:256}
            tag=${tag,,}
            if [ -d "data/${tag}" ]; then
                cp $WORKING_DIR/composer.phar data/${tag}/
                cp $WORKING_DIR/Dockerfile data/${tag}/
                cp $WORKING_DIR/lemp.sh data/${tag}/
                cp -r $WORKING_DIR/config data/${tag}/
                cd data/${tag}
                (
                    cd repo
                    git pull
                )
            else
                mkdir -p data/${tag}
                # Symlinks seem nice until you realize they copy nothing of substance.
                cp $WORKING_DIR/composer.phar data/${tag}/
                cp $WORKING_DIR/Dockerfile data/${tag}/
                cp $WORKING_DIR/lemp.sh data/${tag}/
                cp -r $WORKING_DIR/config data/${tag}/
                cd data/${tag}
                git clone "https://github.com/$repo" repo
            fi
            BUILD=(${BUILD_CMD[@]})
            BUILD+=("-t=${tag,,}")
            BUILD+=(.)
            "${BUILD[@]}"
            if [ $? != 0 ]; then
                echo "Error on Docker image build..."
            else
                echo "Docker image built successfully!"
            fi
            pause
            ;;
        2)
            echo "Deploying Docker stack..."
            echo "Which image do you want to base the container off of?"
            read image
            echo "What name do you want to give to the stack?"
            read name
            if [ -z "$name" ]; then
                echo "Name not provided. Reverting to default..."
                name=$image
            fi
            echo "Which external port do you want to bind to the container?"
            read port
            mkdir -p data/${image}
            mkdir -p data/${image}/${name}
            cat docker-compose.yml | sed --expression "s/image_name/${image}/" --expression "s/http_port/${port}/" > data/${image}/${name}/docker-compose.yml
            cd data/${image}/${name}
            docker-compose pull
            docker-compose build
            docker-compose up -d
            if [ $? != 0 ]; then
                echo "Error on Docker stack deployment..."
            else
                echo "Docker stack deployed successfully!"
            fi
            pause
            ;;
        3)
            echo "Deploying development environment..."
            echo "What is the absolute path to the development directory? (ex. /home/tehtotalpwnage/git/DLEMP)"
            read path
            echo "What is the UID of your development user?"
            read uid
            echo "What is the GID of your development group?"
            read gid
            # tag=${path:`expr index "$path" /`:256}
            tag=${path##/*/}
            # docker build --build-arg uid=$uid --build-arg gid=$gid -f dockerfiles/dev-dockerfile -t=${tag,,}_dev .
            # echo "Deploying Docker container..."
            echo "Which external port do you want to bind to the container?"
            read port
            echo "Deploying Docker container..."
            mkdir -p data/${tag,,}_dev
            cp -r config data/${tag,,}_dev/
            cp dockerfiles/Dockerfile.dev data/${tag,,}_dev/Dockerfile.dev
            cat dev-docker-compose.yml | sed --expression "s#repo_path#${path}#g" --expression "s/image_name/${tag,,}_dev/" \
            --expression "s/http_port/${port}/" --expression "s/user_id/$uid/" --expression "s/group_id/$gid/" \
            > data/${tag,,}_dev/docker-compose.yml
            # cat dev-docker-compose.yml | sed --expression "s#repo_path#${path}#" --expression "s/image_name/${tag,,}_dev/" --expression "s/http_port/${port}/" > data/${tag,,}_dev/docker-compose.yml
            cd data/${tag,,}_dev
            docker-compose up -d
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
            if [[ $CACHE_UPDATE = true ]]; then
                date +%D > data/CACHE
            fi
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

cd "$(dirname "$(readlink -f "$0")")"
mkdir -p data
touch data/CACHE
CACHE="$(cat data/CACHE)"
if [[ -z "$CACHE" ]]; then
    cache
    args "$@"
else
    IFS='/' read -ra CACHE <<< $CACHE
    IFS='/' read -ra NOW <<< $(date +%D)
    CACHE=$((10#${CACHE[0]} * 30 + 10#${CACHE[1]} + 10#${CACHE[2]} * 365))
    NOW=$((10#${NOW[0]} * 30 + 10#${NOW[1]} + 10#${NOW[2]} * 365))
    if [[ $(($NOW - $CACHE)) -gt 7 ]]; then
        cache
    fi
    args "$@"
fi
