#!/bin/bash

function menu {
    clear
    echo "The Docker LEMP Container Management Program (DLEMP)"
    echo "Created by Michael Nguyen (TehTotalPwnage)"
    echo "Actions"
    echo "-------"
    echo "1) Build Docker Image"
    echo "2) Deploy Docker Container"
    echo "3) Exit"
    read option
    case $option in
        1)
            echo "Building Docker image..."
            echo "Which Git repo would you like to clone onto the server?"
            echo "Give your response in the form of USERNAME/REPOSITORY (ex. TehTotalPwnage/DLEMP)"
            read repo
            docker build . --build-arg REPO=$repo
            echo "Docker image built successfully!"
            menu
            ;;
        2)
            ;;
        3)
            echo "Now exiting..."
            echo "If you like this project, please star it on GitHub: https://github.com/TehTotalPwnage/DLEMP"
            echo "If you'd like to support me, consider donating on Patreon: https://patreon.com/tehtotalpwnage"
            exit 0
            ;;
        *)
    esac
}
