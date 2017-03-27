#!/bin/bash

function menu {
    clear
    echo "The Docker LEMP Container Management Program (DLEMP)"
    echo "Created by Michael Nguyen (TehTotalPwnage)"
    echo "Actions"
    echo "-------"
    echo "1) Build Docker Image"
    echo "2) Deploy Docker Container"
    echo "3) Save Build Configuration"
    echo "4) Edit Settings"
    echo "5) Exit"
    read option
    case $option in
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
            echo "Press any key to continue..."
            read -n 1
            menu
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
                echo "Error on Docker container deployment... Press any key to continue..."
            else
                echo "Docker container deployed successfully! Press any key to continue..."
            fi
            read -n 1
            menu
            ;;
        3)
            echo "Which Git repo do you want to use for the server image builds?"
            echo "Give your response in the form of USERNAME/REPOSITORY (ex. TehTotalPwnage/DLEMP)"
            read repo
            ;;
        4)
            echo "Function still in development."
            menu
            ;;
        5)
            echo "Now exiting..."
            echo "If you like this project, please star it on GitHub: https://github.com/TehTotalPwnage/DLEMP"
            echo "If you'd like to support me, consider donating on Patreon: https://patreon.com/tehtotalpwnage"
            exit 0
            ;;
        *)
            echo "Unrecognized command. Please enter another command."
            menu
            ;;
    esac
}
menu
