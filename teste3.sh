#!/usr/bin/env bash

MY_OPTIONS="+ssse3,+sse4.2,+aes"

ALLOCATED_RAM="4096" # 4 GB de RAM
CPU_SOCKETS="1"
CPU_CORES="4"  # Ajuste conforme o número de núcleos físicos do seu processador
CPU_THREADS="4" # Ajuste conforme o número de núcleos físicos do seu processador

REPO_PATH="."
OVMF_DIR="."

args=(
  -m "$ALLOCATED_RAM" -cpu host,+ssse3,+sse4.2,+aes
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
  -device virtio-gpu-pci
  -drive id=OpenCoreBoot,if=virtio,snapshot=on,format=qcow2,file="$REPO_PATH/OpenCore/OpenCore.qcow2",cache=writeback
  -device virtio-blk-pci,drive=OpenCoreBoot
  -device virtio-blk-pci,drive=InstallMedia
  -drive id=InstallMedia,if=none,file="$REPO_PATH/BaseSystem.img",format=raw
  -drive id=MacHDD,if=virtio,file="$REPO_PATH/mac_hdd_ng.img",format=qcow2,cache=writeback
  -monitor stdio
  -M accel=kvm
)

