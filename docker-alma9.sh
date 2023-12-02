#!/bin/bash

dnf in epel-release -y
dnf install -y yum-utils device-mapper-persistent-data lvm2 libxcrypt-compat epel-release git nano htop mc atop
dnf remove podman buildah
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install docker-ce docker-ce-cli containerd.io --nobest
usermod -aG docker $(whoami)
systemctl enable --now docker
docker -v
curl -L "https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose -v
firewall-cmd --zone=public --add-masquerade --permanent
firewall-cmd --reload

