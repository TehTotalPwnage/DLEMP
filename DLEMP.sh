#!/bin/bash

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
        echo "5) Setup Dev Environment"
        echo "6) Update Package Sources"
        echo "7) Edit Settings"
        echo "8) Exit"
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
            docker build -t=${tag,,} .
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
            docker build -f dockerfiles/dev-dockerfile -t=${tag,,} .
            echo "Deploying Docker container..."
            echo "Which external port do you want to bind to the container?"
            read port
            docker create --name "${tag,,}_dev" --publish $port:80 --volume $path:/srv/mnt ${tag,,} start dev
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
            echo "Setting up development environment..."
            echo "Would you like to update the dependencies first (1) or install the environment now (2)?"
            read -n 1 install
            case $install in
                1)
                    menu 5
                    ;&
                2)
                    echo "Installing..."
                    echo "Deploying MySQL container..."
                    docker create --name dlemp_mysql_container --publish 3306:3306 dlemp_mysql
                    echo "MySQL deployment successful!"
                    echo "Environment setup successful!"
                    pause
                    ;;
                *)
                    echo "Unrecognized command. Please enter another command."
                    pause
                    ;;
            esac
            ;;
        6)
            echo "Running the update script..."
            docker build -t=dlemp_mysql
            echo "Dependencies updated!"
            pause
            ;;
        7)
            echo "Function is a work in progress. Come back later!"
            pause
            ;;
        8)
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

while true; do
    menu
done
