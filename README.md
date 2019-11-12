# skarp@'s firecracker-containerd demo Packer script

Yes, it's a packer script.  This is designed to generate an AMI suitable for
demoing firecracker-containerd with all of the relevant bits installed.

This builds on Debian 10 (Buster).

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
