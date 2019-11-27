#!/bin/bash

########################
# include the magic
########################
. .magic/demo-magic.sh

# hide the evidence
clear

# Debian Buster with all the firecracker-containerd tools installed
# Look at what's installed
# Everything is in /usr/local/bin
# * firecracker-containerd - our custom containerd binary with a built-in plugin to manage virtual machine lifecycle
# * firecracker - Actual firecracker VMM
# * containerd-shim-aws-firecracker - our V2 runtime that handles container lifecycle inside the VM
# * ecr-pull - custom resolver for pulling images from ECR
pe "ls -l /usr/local/bin"
sudo systemctl start firecracker-containerd >/dev/null 2>/dev/null
pe "sudo systemctl status firecracker-containerd"
pe "cat /etc/systemd/system/firecracker-containerd.service"

# Let's look at what images are here
fctr i rm ecr.aws/arn:aws:ecr:us-west-2:137112412989:repository/amazonlinux:latest >/dev/null 2>/dev/null
pe "fctr i ls"

# Let's try pulling an image from ECR
pe "ecr-pull ecr.aws/arn:aws:ecr:us-west-2:137112412989:repository/amazonlinux:latest"
pe "fctr i ls"

# Let's see what it looks like to run it
pe "uname -a"
pe "cat /etc/os-release"
pe "fctr run --runtime aws.firecracker --rm --tty ecr.aws/arn:aws:ecr:us-west-2:137112412989:repository/amazonlinux:latest demo"

# Do the same inside the VM
# uname -a -> an Amazon Linux kernel (amzn2) with a different hostname
# cat /etc/os-release -> same thing you'd see in Docker, this is a normal container inside a VM

# Let's look at what happens on the host
fctr c rm demo-sleep >/dev/null 2>/dev/null
pe "fctr run --runtime aws.firecracker --rm --detach ecr.aws/arn:aws:ecr:us-west-2:137112412989:repository/amazonlinux:latest demo-sleep sleep 60"
pe "pidof firecracker-containerd"
pe "sudo pstree -sS $(pidof firecracker-containerd)"

p "# Done!"
