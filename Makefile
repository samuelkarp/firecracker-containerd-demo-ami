all: ami


SUBMODULES=_submodules
INSTALL=fakeroot install -D -o root -g root
INSTALL_EXE=$(INSTALL) -m755

.PHONY: ami
ami: ami-stamp
ami-stamp: files.tar.gz packer.json
	packer build packer.json
	touch $@

files.tar.gz: firecracker-containerd fc-rootfs fc-config kernel ecr-resolver demo
	tree files
	tar cvzf files.tar.gz -C files .

.PHONY: firecracker-containerd
firecracker-containerd: firecracker-containerd-stamp
firecracker-containerd-stamp: $(SUBMODULES)/firecracker-containerd
	INSTALLROOT=$(PWD)/files/usr/local fakeroot $(MAKE) -C $(SUBMODULES)/firecracker-containerd install install-firecracker
	touch $@

.PHONY: fc-rootfs
fc-rootfs: files/var/lib/firecracker-containerd/runtime/default-rootfs.img
files/var/lib/firecracker-containerd/runtime/default-rootfs.img: $(SUBMODULES)/firecracker-containerd
	$(MAKE) -C $(SUBMODULES)/firecracker-containerd image
	$(INSTALL) -m644 -T $(SUBMODULES)/firecracker-containerd/tools/image-builder/rootfs.img files/var/lib/firecracker-containerd/runtime/default-rootfs.img

.PHONY: fc-config
fc-config: files/etc/containerd/{config.toml,firecracker-runtime.json} files/etc/systemd/system/firecracker-containerd.service files/usr/local/libexec/devmapper-setup.sh
files/etc/containerd/{config.toml,firecracker-runtime.json}: containerd-config.toml firecracker-runtime.json
	$(INSTALL) -m644 -T containerd-config.toml files/etc/containerd/config.toml
	$(INSTALL) -m644 -T firecracker-runtime.json files/etc/containerd/firecracker-runtime.json
files/etc/systemd/system/firecracker-containerd.service: firecracker-containerd.service
	$(INSTALL) -m644 -T firecracker-containerd.service files/etc/systemd/system/firecracker-containerd.service
files/usr/local/libexec/devmapper-setup.sh: devmapper-setup.sh
	$(INSTALL_EXE) -T devmapper-setup.sh files/usr/local/libexec/devmapper-setup.sh

.PHONY: kernel
kernel: files/var/lib/firecracker-containerd/runtime/hello-vmlinux.bin
files/var/lib/firecracker-containerd/runtime/hello-vmlinux.bin:
	mkdir -p files/var/lib/firecracker-containerd/runtime
	curl -fsSL -o files/var/lib/firecracker-containerd/runtime/hello-vmlinux.bin https://s3.amazonaws.com/spec.ccfc.min/img/hello/kernel/hello-vmlinux.bin

.PHONY: ecr-resolver
ecr-resolver: files/usr/local/libexec/ecr-{pull,push,copy}
files/usr/local/libexec/ecr-{pull,push,copy}: $(SUBMODULES)/amazon-ecr-containerd-resolver
	$(MAKE) -C $(SUBMODULES)/amazon-ecr-containerd-resolver
	$(INSTALL_EXE) -t files/usr/local/libexec $(SUBMODULES)/amazon-ecr-containerd-resolver/bin/ecr-*

.PHONY: demo
demo: demo-magic files/usr/local/bin/{fctr,ecr-pull} files/home/admin/demo.sh
files/usr/local/bin/{fctr,ecr-pull}:
	$(INSTALL_EXE) -t files/usr/local/bin fctr ecr-pull
files/home/admin/demo.sh:
	$(INSTALL) -m777 -t files/home/admin demo.sh

.PHONY: demo-magic
demo-magic: files/home/admin/.magic/demo-magic.sh
files/home/admin/.magic/demo-magic.sh: $(SUBMODULES)/demo-magic
	$(INSTALL) -t files/home/admin/.magic $(SUBMODULES)/demo-magic/demo-magic.sh $(SUBMODULES)/demo-magic/license.txt

.PHONY: clean
clean:
	$(MAKE) -C $(SUBMODULES)/firecracker-containerd clean
	$(MAKE) -C $(SUBMODULES)/amazon-ecr-containerd-resolver clean
	rm -rf files files.tar.gz
	rm -f *-stamp
