#!/bin/bash
# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

########################
# include the magic
########################
. .magic/demo-magic.sh

# Make "typing" happen faster
TYPE_SPEED=100

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

# Let's look at how containerd is configured
pe "cat /etc/containerd/config.toml"
# You can see that the devicemapper snapshotter is configured here
# It's now a built-in plugin, but you would see the address if it were a proxy plugin

# Let's look at what images are here
ctr i rm ecr.aws/arn:aws:ecr:us-west-2:137112412989:repository/amazonlinux:latest >/dev/null 2>/dev/null
pe "ctr i ls"

# Let's try pulling an image from ECR
pe "ecr-pull ecr.aws/arn:aws:ecr:us-west-2:137112412989:repository/amazonlinux:latest"
pe "ctr i ls"

# Let's see what it looks like to run it
# First let's look at what's on the host
pe "uname -a"
pe "cat /etc/os-release"
# Let's run a regular container, using the default runtime of runc
pe "ctr run --rm --tty ecr.aws/arn:aws:ecr:us-west-2:137112412989:repository/amazonlinux:latest demo-runc"
# Run the same commands
# uname -a -> same kernel
# cat /etc/os-release -> same thing you'd see in Docker, this is a normal container inside a VM

# Now let's do it with our custom runtime and run a virtual machine
pe "ctr run --runtime aws.firecracker --rm --tty ecr.aws/arn:aws:ecr:us-west-2:137112412989:repository/amazonlinux:latest demo-firecracker"
# Do the same inside the VM
# uname -a -> an Amazon Linux kernel (amzn2) with a different hostname
# cat /etc/os-release -> same thing you'd see in Docker, this is a normal container inside a VM

# Let's look at what happens on the host
ctr c rm demo-sleep-runc >/dev/null 2>/dev/null
ctr c rm demo-sleep-fc >/dev/null 2>/dev/null
# Look at a regular container first
pe "ctr run --rm --detach ecr.aws/arn:aws:ecr:us-west-2:137112412989:repository/amazonlinux:latest demo-sleep-runc sleep 60"
pe "pidof sleep"
pe "sudo pstree -sS $(pidof sleep)"
# okay, let's get rid of this one
pe "ctr t kill -s 9 demo-sleep-runc"
pe "ctr c rm demo-sleep-runc"

# Now let's look at the same thing in firecracker
pe "ctr run --runtime aws.firecracker --rm --detach ecr.aws/arn:aws:ecr:us-west-2:137112412989:repository/amazonlinux:latest demo-sleep-fc sleep 60"
pe "pidof sleep"
# We don't see sleep
# What do we see instead?
pe "pidof firecracker-containerd"
pe "sudo pstree -sS $(pidof firecracker-containerd)"

wait
