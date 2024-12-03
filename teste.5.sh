#!/usr/bin/env bash

# Configurações de CPU
MY_OPTIONS="+ssse3,+sse4.2,+popcnt,+aes,+xsave,+xsaveopt,check"
ALLOCATED_RAM="8192"  # 8 GB de RAM
CPU_SOCKETS="1"
CPU_CORES="2"
CPU_THREADS="2"

# Caminhos dos arquivos
REPO_PATH="."
OVMF_DIR="."

# Argumentos para o QEMU
args=(
  -m "$ALLOCATED_RAM"                           # Aloca 8 GB de RAM
  #-cpu host
  -cpu Haswell,+sse4.1,+sse4.2,+avx,+avx2,+aes,+xsave,+xsaveopt,+popcnt,+vmx,+fma,+tsc-deadline,+bmi2,+tbm  # Melhora o desempenho de CPU para tarefas gráficas e cálculo pesado
  #-cpu Skylake,+sse4.1,+sse4.2,+avx,+avx2,+aes,+xsave,+xsaveopt,+popcnt,+vmx,+fma,+tsc-deadline,+bmi2,+tbm
  #-cpu Skylake-Client-v4,+sse4.1,+sse4.2,+avx,+avx2,+aes,+xsave,+xsaveopt,+popcnt,+vmx,+fma,+tsc-deadline,+bmi2,+tbm
  #-cpu Broadwell,+sse4.1,+sse4.2,+avx,+avx2,+aes,+xsave,+xsaveopt,+popcnt,+vmx,+fma,+tsc-deadline,+bmi2
  #-cpu Cascadelake-Server-v5,+sse4.1,+sse4.2,+avx,+avx2,+aes,+xsave,+xsaveopt,+popcnt,+vmx,+fma,+tsc-deadline,+bmi2
  #-cpu Cascadelake-Server-v5,+sse4.1,+sse4.2,+aes,+xsave,+avx,+avx2
  #-cpu Cascadelake-Server,-avx512f,-avx512dq,-avx512cd,-avx512bw,-avx512vl,-pku,-avx512vnni,-hle,-rtm,-clwb
  #-cpu Cascadelake-Server,+sse4.1,+sse4.2,+avx,+avx2,+aes,+xsave,+xsaveopt,+popcnt,+vmx,+fma,+tsc-deadline,+bmi2,+tbm,-avx512cd,-avx512bw,-avx512vl,-pku,-tbm,-avx512vnni,-hle,-rtm,-avx512dq,-clwb,-avx512f,-vmx-apicv-register,-vmx-apicv-vid,-vmx-posted-intr
  -machine q35                                  # Usar a máquina Q35 para melhor compatibilidade
  -usb -device usb-kbd -device usb-tablet        # Habilitar entrada USB e tablet
  -smp "$CPU_THREADS",cores="$CPU_CORES",sockets="$CPU_SOCKETS"  # Número de núcleos e threads da CPU
  -device usb-ehci,id=ehci                      # Controlador USB EHCI
  -device nec-usb-xhci,id=xhci                  # Controlador USB XHCI
  -global nec-usb-xhci.msi=off                  # Desabilita MSI no controlador USB
  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"  # Aceleração de SMC para macOS
  -drive if=pflash,format=raw,readonly=on,file="$REPO_PATH/$OVMF_DIR/OVMF_CODE.fd"  # Firmware OVMF (EFI)
  -drive if=pflash,format=raw,file="$REPO_PATH/$OVMF_DIR/OVMF_VARS-1024x768.fd"  # Variáveis EFI
  -smbios type=2                                # Define o SMBIOS (informações sobre o hardware)
  -device ich9-intel-hda -device hda-duplex     # Áudio em emulação Intel HD Audio
  -device ich9-ahci,id=sata                     # Controlador SATA AHCI
  -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$REPO_PATH/OpenCore/OpenCore.qcow2",cache=none  # Drive do OpenCore
  -device ide-hd,bus=sata.2,drive=OpenCoreBoot  # Conectar o drive do OpenCore ao barramento SATA
  -device ide-hd,bus=sata.3,drive=InstallMedia # Drive de instalação do macOS
  -drive id=InstallMedia,if=none,file="$REPO_PATH/BaseSystem.img",format=raw  # Imagem de instalação do macOS
  -drive id=MacHDD,if=none,file="$REPO_PATH/mac_hdd_ng.img",format=qcow2,cache=none  # Drive de disco do macOS
  -device ide-hd,bus=sata.4,drive=MacHDD       # Conectar o disco rígido do macOS ao barramento SATA
  -netdev user,id=net0 -device virtio-net-pci,netdev=net0  # Configuração de rede (Virtio)
  
  # Aceleração gráfica
  #-vga virtio                               # Usar Virtio para aceleração gráfica
  #-vga  vmware                               # Usar Virtio para aceleração gráfica
  #-device virtio-gpu
  #-device cirrus-vga
  #-device qxl,ram_size=128
  -device virtio-vga
  -spice port=5900,disable-ticketing=on
  #-spice port=5900,disable-ticketing
  #-vga virtio
  #-device usb-tablet
  #-device vmware-svga
  #-device qxl                               # Habilitar QXL para aceleração gráfica (pode ser usado com Spice)
  #-spice port=5930,addr=127.0.0.1,disable-ticketing=on  # Habilitar Spice para renderização gráfica via rede (opcional)
  #-device virtio-gpu,vram=64M

  # Aceleração de CPU (KVM)
  -M accel=kvm                              # Usar aceleração KVM (se disponível)
  
  -monitor stdio                           # Exibir monitor no terminal
)

# Iniciar o QEMU com os argumentos configurados
qemu-system-x86_64 "${args[@]}"

