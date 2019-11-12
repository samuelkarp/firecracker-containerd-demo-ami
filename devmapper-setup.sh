#!/bin/bash

# Sets up a devicemapper thin pool with loop devices in
# /var/lib/firecracker-containerd/snapshotter/devmapper

set -ex

DIR=/var/lib/firecracker-containerd/snapshotter/devmapper
POOL=demo

mkdir -p "${DIR}"

DATADEV="$(losetup --output NAME --noheadings --associated ${DIR}/data)"
if [[ -z "${DATADEV}" ]]; then
  DATADEV="$(losetup --find --show ${DIR}/data)"
fi

METADEV="$(losetup --output NAME --noheadings --associated ${DIR}/meta)"
if [[ -z "${METADEV}" ]]; then
  METADEV="$(losetup --find --show ${DIR}/meta)"
fi

SECTORSIZE=512
DATASIZE="$(blockdev --getsize64 -q ${DATADEV})"
LENGTH_SECTORS=$(bc <<< "${DATASIZE}/${SECTORSIZE}")
DATA_BLOCK_SIZE=128 # see https://www.kernel.org/doc/Documentation/device-mapper/thin-provisioning.txt
LOW_WATER_MARK=32768 # picked arbitrarily
THINP_TABLE="0 ${LENGTH_SECTORS} thin-pool ${METADEV} ${DATADEV} ${DATA_BLOCK_SIZE} ${LOW_WATER_MARK} 1 skip_block_zeroing"
echo "${THINP_TABLE}"

if ! $(dmsetup reload "${POOL}" --table "${THINP_TABLE}"); then
  dmsetup create "${POOL}" --table "${THINP_TABLE}"
fi
