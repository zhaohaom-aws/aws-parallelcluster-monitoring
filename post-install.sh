#!/bin/bash
#
#
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Usage: ./post-install [version]

#Load AWS Parallelcluster environment variables
. /etc/parallelcluster/cfnconfig

version=${1:-v1.0}
monitoring_dir_name=aws-parallelcluster-monitoring
monitoring_tarball="${monitoring_dir_name}.tar.gz"

#get GitHub repo to clone and the installation script
monitoring_url=https://github.com/zhaohaom-aws/aws-parallelcluster-monitoring/archive/refs/tags/${version}.tar.gz
setup_command=install-monitoring.sh
monitoring_home="/home/${cfn_cluster_user}/${monitoring_dir_name}"

case ${cfn_node_type} in
    HeadNode | MasterServer)
        wget ${monitoring_url} -O ${monitoring_tarball}
        mkdir -p ${monitoring_home}
        tar xvf ${monitoring_tarball} -C ${monitoring_home} --strip-components 1
    ;;
    ComputeFleet)
    
    ;;
esac

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker run hello-world

#Execute the monitoring installation script
bash -x "${monitoring_home}/parallelcluster-setup/${setup_command}" >/tmp/monitoring-setup.log 2>&1
exit $?
