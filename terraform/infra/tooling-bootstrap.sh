#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y git ansible

mkdir -p /opt/devops-bootstrap
cd /opt/devops-bootstrap

if [ ! -d todo-project ]; then
  git clone -b Jenkins https://github.com/Tupesh/todo-project.git
fi

cd todo-project/ansibleplaybook

ansible-playbook -i localhost, -c local tooling.yml