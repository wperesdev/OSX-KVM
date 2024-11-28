#!/usr/bin/env bash

MY_OPTIONS="+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"

ALLOCATED_RAM="4096" # 8 GB de RAM
CPU_SOCKETS="1"
CPU_CORES="4"
CPU_THREADS="4"

REPO_PATH="."
OVMF_DIR="."

args=(
  -m "$ALLOCATED_RAM" -cpu host,+avx2,+ssse3,+sse4.2,+aes,+xsave,+xsaveopt,+popcnt,"$MY_OPTIONS"
  #-m "$ALLOCATED_RAM" -cpu host,+ssse3,+sse4.2,+aes
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
  -device virtio-gpu-pci #,virgl=on # Melhorias gráficas
  -drive id=OpenCoreBoot,if=virtio,snapshot=on,format=qcow2,file="$REPO_PATH/OpenCore/OpenCore.qcow2",cache=writeback # Melhoria de disco
  #-device virtio-blk-pci,drive=OpenCoreBoot
  -device virtio-blk-pci,drive=InstallMedia
  #-device virtio-blk-pci,drive=MacHDD
  #-device virtio-gpu-pci
  -drive id=InstallMedia,if=none,file="$REPO_PATH/BaseSystem.img",format=raw,cache=writeback
  -drive id=MacHDD,if=virtio,file="$REPO_PATH/mac_hdd_ng.img",format=qcow2,cache=writeback
  #-netdev tap,id=net0 -device virtio-net-pci,netdev=net0,id=net0,mac=52:54:00:c9:18:27 # Melhor desempenho de rede
  -monitor stdio
  -M accel=kvm
)

qemu-system-x86_64 "${args[@]}"

