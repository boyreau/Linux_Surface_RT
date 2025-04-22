### Arch linux boot partition for Microsoft Surface RT1

/efi/boot/bootarm.efi:
    entrypoint called by the firmware
    it is a fix for the broken GOP (makes display work)
    calls /boot.efi

/boot.efi:
    EFI Shell from TianoCore EDK II project

/set\_startup.sh:
    A shell scripts that moves startup.nsh to startup.nsh.bak, and that moves startup.nsh.risky to startup.nsh.
    Configure the risky startup script, and call this script to use it on the next boot.
    Subsequent boot will use the original startup.nsh so your machine will not stay stuck even if your risky configuration fails.
    Be careful not to override or erase anything required by the original startup.nsh.

/startup.nsh:
    EFI Shell script that is automatically read on boot.
    Required because the keyboard does not work.
    It will call linux kernel with some required argument, a DTB and an initramfs.

/startup.nsh.risky:
    EFI Shell script that is restores startup.nsh.bak on boot.
    Useful if you want to test a one-time risky configuration without bricking your device.
    Feel free to experiment with kernel arguments or EFI binaries.

/linux-X.Y.Z/vmlinuz-X.Y.Z:
    An ARM32 linux kernel

/linux-X.Y.Z/tegra30-microsoft-surface-rt-efi.dtb:
    A device tree blob containing a description of the hardware embedded in the Surface RT

/linux-X.Y.Z/initramfs-X.Y.Z.img:
    An initramfs to load early kernel modules and set up the real root filesystem if required.

