# skarp@'s firecracker-containerd demo Packer script

Yes, it's a packer script.  This is designed to generate an AMI suitable for
demoing firecracker-containerd with all of the relevant bits installed.

This builds on Debian 10 (Buster).

## Demos

The following demos are included in this repository (and built into the same
image):

1. `kubecon.sh` - Demo for "Extending containerd" at KubeCon/CloudNativeCon NA
   2019
2. `reinvent.sh` - Demo for "Deep Dive into firecracker-containerd" at re:Invent
   2019

## Requirements

* A working set of AWS credentials
* Packer
* Git submodules (run `git submodule udpate --init --recursive` when you check
  this repo out in order to grab all of the bits)
* Docker
* Go

## Building

Run `make`.

## Updating

Dependencies are managed as git submodules and are in the `_submodules` folder.

## Errata

* runc's Makefile "install" target does not build a binary.  Instead, we use the
  target defined in firecracker-containerd's image-builder Makefile.
* containerd's Makefile "install" target does not build binaries.  Instead, we
  build each of the binaries that we wish to use independently and install them
  explicitly.
* The `firecracker-containerd` binary appears to be unable to run containers
  with the upstream v1 or v2 runc shims.  Instead, we use `go install` in the
  context of the `firecracker-containerd` submodule to build the shims with the
  set of dependencies used by firecracker-containerd.
