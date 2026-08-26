#!/bin/bash

set -ex

# export DISKS='vdc vdd vde'
if [ -z "${DISKS}" ]; then
    echo "ERROR: DISKS not set"
    exit 1
fi

if [ 0 -eq 1 ]; then
    ./autogen.sh
    ./configure # --enable-debug
fi
if [ 1 -eq 1 ]; then
    make -j$(nproc)
    make module -j$(nproc)
    sudo make install
    sudo make -C module install
fi
sudo ldconfig
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo udevadm settle
hash -r
sudo systemctl stop zfs-zed.service
sudo ./scripts/zfs.sh -u
sudo rm -rf /var/tmp/test_results/

#./scripts/zfs-tests.sh # -v
#./scripts/zfs-tests.sh -T channel_program
./scripts/zfs-tests.sh -t tests/functional/cli_root/zfs_destroy/zfs_destroy_017_pos.ksh
#export BOOKMARK_COUNT=1000
#./scripts/zfs-tests.sh -t tests/functional/channel_program/synctask_core/tst.bookmark_destroy_cli.ksh
#./scripts/zfs-tests.sh -t tests/functional/channel_program/synctask_core/tst.bookmark_destroy_capi.ksh
#./scripts/zfs-tests.sh -t tests/functional/channel_program/synctask_core/tst.bookmark_destroy_channel.ksh
