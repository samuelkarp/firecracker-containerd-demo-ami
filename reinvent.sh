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

# hide the evidence
clear

image="docker.io/nmeyerhans/stress:latest"

sudo systemctl start firecracker-containerd >/dev/null 2>/dev/null
fctr i pull "${image}" >/dev/null 2>/dev/null

# Let's try running an image that has a common Linux program called "stress" in
# a standard Linux container with containerd and the ctr tool.
# Here we've configured "stress" to use 2 threads that consume CPU
pe "ctr run --detach --env CPU_THREADS=2 ${image} stress-runc"

# While stress runs, we can examine the running state of the system, as viewed
# from the host.
# We can see the stress program and its constituent threads visible as normal,
# first-class process objects
pe "pgrep stress"

# Beyond seeing the processes, we can see their inheritance.
# Each stress thread is a child of the main stress process, which runs under an
# entrypoint program (called "entrypoint" in this example), running under
# containerd.
pe "sudo pstree -sSc $(pgrep --oldest stress)"

# And we can see stress using system resources
pe "sudo top -p $(pgrep stress | tr '\n' ',' | head -c -1) -b -n1"

# Let's go ahead and clean that up
p "ctr t kill stress-runc && ctr t rm stress-runc && ctr c rm stress-runc"
ctr t kill stress-runc >/dev/null 2>/dev/null
sleep 1
ctr t rm stress-runc >/dev/null 2>/dev/null
sleep 1
ctr c rm stress-runc >/dev/null 2>/dev/null

# Now we'll run the same stress container, but inside a Firecracker VM with
# firecracker-containerd
pe "ctr run --detach --env CPU_THREADS=2 --runtime aws.firecracker ${image} stress-fc"

# Inspecting the running state of the system, as viewed from the host, shows
# that the stress command isn't visible on this system
pe "pgrep stress"

# But Firecracker is running
pe "pgrep -x firecracker"

# We can look at what Firecracker looks like
pe "sudo pstree -sSc $(pgrep -x --oldest firecracker)"

# And we can see firecracker using system resources
pe "sudo top -p $(pgrep -x --oldest firecracker) -b -n1"

p "# Done!"
ctr t kill stress-fc >/dev/null 2>/dev/null
ctr t rm stress-fc >/dev/null 2>/dev/null
ctr c rm stress-fc >/dev/null 2>/dev/null
