#!/usr/bin/env bash

MY_OPTIONS="+ssse3,+sse4.2,+popcnt,+aes,+xsave,+xsaveopt,check"

ALLOCATED_RAM="8192" # 8 GB de RAM
CPU_SOCKETS="1"
CPU_CORES="2"
CPU_THREADS="2"

REPO_PATH="."
OVMF_DIR="."

args=(
  -m "$ALLOCATED_RAM" -cpu host,+sse4.2,+avx,+aes,+xsave,+xsaveopt,+popcnt,"$MY_OPTIONS"
  -machine q35
  -usb -device usb-kbd -device usb-tablet
  -smp "$CPU_THREADS",cores="$CPU_CORES",sockets="$CPU_SOCKETS"
  -device usb-ehci,id=ehci
  -device nec-usb-xhci,id=xhci
  -global nec-usb-xhci.msi=off
  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
  -drive if=pflash,format=raw,readonly=on,file="$REPO_PATH/$OVMF_DIR/OVMF_CODE.fd"
  -drive if=pflash,format=raw,file="$REPO_PATH/$OVMF_DIR/OVMF_VARS-1024x768.fd"
  -smbios type=2
  -device ich9-intel-hda -device hda-duplex
  -device ich9-ahci,id=sata
  -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$REPO_PATH/OpenCore/OpenCore.qcow2",cache=none
  -device ide-hd,bus=sata.2,drive=OpenCoreBoot
  -device ide-hd,bus=sata.3,drive=InstallMedia
  -drive id=InstallMedia,if=none,file="$REPO_PATH/BaseSystem.img",format=raw
  -drive id=MacHDD,if=none,file="$REPO_PATH/mac_hdd_ng.img",format=qcow2,cache=none
  -device ide-hd,bus=sata.4,drive=MacHDD
  -netdev user,id=net0 -device virtio-net-pci,netdev=net0
  -monitor stdio
  -device VGA
  -M accel=kvm
  #-device qxl,ram_size=128
  #-spice port=5930,addr=127.0.0.1,disable-ticketing=on
)

qemu-system-x86_64 "${args[@]}"
