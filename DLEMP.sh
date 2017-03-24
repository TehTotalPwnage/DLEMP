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
            docker build --build-arg REPO=$repo -t=$repo .
            echo "Docker image built successfully!"
            menu
            ;;
        2)
            echo "Deploying Docker container..."
            echo "Which image do you want to base the container off of?"
            read image
            echo "Do you want to link a development volume to the container? Leave blank or provide a path:"
            read $volume
            if [ -n "$volume" ]; then
                echo "Should this container boot to the development environment setup by default? 1) Yes 2) No"
            fi
            docker run --detach --name $image $image
            menu
            ;;
        3)
            echo "Which Git repo do you want to use for the server image builds?"
            echo "Give your response in the form of USERNAME/REPOSITORY (ex. TehTotalPwnage/DLEMP)"
            read repo
        4)
            echo "Now exiting..."
            echo "If you like this project, please star it on GitHub: https://github.com/TehTotalPwnage/DLEMP"
            echo "If you'd like to support me, consider donating on Patreon: https://patreon.com/tehtotalpwnage"
            exit 0
            ;;
        *)
    esac
}
