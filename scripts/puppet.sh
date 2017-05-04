#!/bin/bash

# Based upon https://github.com/garethr/puppet-docker-swarm-example

red='\e[0;31m'
orange='\e[0;33m'
green='\e[0;32m'
end='\e[0m'

# Check to see if Puppet is installed
if which /usr/bin/puppet > /dev/null 2>&1; then
    echo -e "${orange}----> Puppet is already installed${end}"
    exit 0
fi

echo -e "----> ${green}Upgrading the system packages...${end}"
#sudo yum upgrade -y

echo -e "----> ${green}Installing puppet...${end}"
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
sudo yum install -y puppet facter unzip
