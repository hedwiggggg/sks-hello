#!/bin/bash -e

install -d															"${ROOTFS_DIR}/boot/sks-hello"
install -m 777 files/_detected.wav			"${ROOTFS_DIR}/boot/sks-hello/"
install -m 777 files/_ready.wav					"${ROOTFS_DIR}/boot/sks-hello/"

install -d															"${ROOTFS_DIR}/home/sks/hello"
install -m 777 files/main.py						"${ROOTFS_DIR}/home/sks/hello/"
install -m 777 files/requirements.txt		"${ROOTFS_DIR}/home/sks/hello/"
install -m 777 files/run-sks-hello.sh		"${ROOTFS_DIR}/home/sks/hello/"

install -m 644 files/sks-hello.service	"${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
sudo chmod +x /home/sks/hello/run-sks-hello.sh

cd /home/sks/hello
sudo python3 -m pip install -r requirements.txt

sudo systemctl daemon-reload
sudo systemctl enable sks-hello.service
EOF
