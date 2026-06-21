#!/bin/bash

sudo apt update
sudo apt install fontconfig openjdk-21-jre -y
java -version

sudo mkdir -p /home/ubuntu/jenkins-agent