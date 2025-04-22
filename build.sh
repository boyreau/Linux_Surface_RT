#!/bin/bash

# Useful variables
VERSION=$(make -s kernelrelease)
EFI_DIR=linux-$VERSION
BOOT_DIR=/boot/$EFI_DIR
LINUX=vmlinuz-$VERSION
INITRAMFS=initramfs-$VERSION.img
DTB=tegra30-microsoft-surface-rt-efi.dtb

if [ -z "$(which nproc 2>/dev/null)" ]
then
    MAXPROC=8
else
    MAXPROC=`nproc`
fi

echo $VERSION $EFI_DIR $BOOT_DIR $LINUX $INITRAMFS $DTB $MAXPROC

echo "Recreating output"
rm -rf output
mkdir -p output

# Build kernel
# If this step fail, check that the CROSS-COMPILER option matches your compiler binary name - mine would be armv7l-unknown-linux-gnueabihf- ; yours is probably different
echo "Building kernel"
make ARCH=arm CROSS_COMPILER=arm-linux-gnueabihf- -j $MAXPROC

echo "Copying kernel to ./output"
cp arch/arm/boot/zImage ./output/$LINUX
cp arch/arm/boot/dts/nvidia/$DTB ./output/$DTB

# Install modules. mkinitcpio creates soft link to /lib.
# This leads to no modules embedded in the image
# Installing modules in /lib and creating a symlink should fix this
echo "Installing modules"
make INSTALL_MOD_PATH=./output modules_install

# Generate initramfs for freshly built version (dry-run)
# echo "Initramfs dry-run generation"
# mkinitcpio -k $VERSION

# Generate initramfs for real
# echo "Initramfs real generation"
# mkinitcpio -k $VERSION -g ./output/$INITRAMFS

echo "Installing Linux and initramfs to boot directory"
rm  -rf $BOOT_DIR
mkdir -p $BOOT_DIR

cp -v ./output/$LINUX        $BOOT_DIR/$LINUX
cp -v ./output/$DTB            $BOOT_DIR/$DTB
cp -v ./output/$INITRAMFS    $BOOT_DIR/$INITRAMFS

echo "Creating startup.nsh"
echo 'fs0:' > ./output/startup.nsh
echo "$EFI_DIR\\$LINUX initrd=$EFI_DIR\\$INITRAMFS dtb=$EFI_DIR\\$DTB ignore_loglevel earlyprintk earlycon root=PARTUUID=abcd1234-04 rw rootwait console=tty0 cpuidle.off=1" >> ./output/startup.nsh
echo 'reset -s' >> ./output/startup.nsh

echo "All done ! Copy ./output/startup.nsh to your boot partition or use its content to update your existing startup script."
