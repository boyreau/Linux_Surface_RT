#!/bin/bash

# Useful variables
VERSION=$(make -s kernelrelease)
EFI_DIR=./output/boot/
BOOT_DIR=$EFI_DIR/linux-$VERSION
LINUX=vmlinuz-$VERSION
INITRAMFS=initramfs-$VERSION.img
DTB=tegra30-microsoft-surface-rt-efi.dtb
MAXPROC=4

# if [ -z "$(which nproc 2>/dev/null)" ]
# then
#     MAXPROC=8
# else
#     MAXPROC=`nproc`
# fi

echo $VERSION $EFI_DIR $BOOT_DIR $LINUX $INITRAMFS $DTB $MAXPROC

echo "Recreating output"
rm -rf output
mkdir -p output

# Build kernel
# If this step fail, check that the CROSS-COMPILE option matches your compiler binary name - mine would be armv7l-unknown-linux-gnueabihf- ; yours is probably different
# This compiler should also be in your PATH. Careful, `which gcc` should give your original compiler (not a soft-link to the cross-compiler), and `which arm-linux-gnueabihf-gcc` should give your cross-compiler.
echo "Building kernel"
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j $MAXPROC || exit 1

echo "Copying kernel to ./output"
cp arch/arm/boot/zImage ./output/$LINUX
cp arch/arm/boot/dts/nvidia/$DTB ./output/$DTB

# Install modules. mkinitcpio creates soft link to /lib.
# This leads to no modules embedded in the image
# Installing modules in /lib and creating a symlink should fix this
echo "Installing modules"
make ARCH=arm INSTALL_MOD_PATH=./output modules_install

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
cp -v ./output/$DTB          $BOOT_DIR/$DTB
cp -v ./output/$INITRAMFS    $BOOT_DIR/$INITRAMFS

echo "Creating startup.nsh"
echo 'fs0:' > $EFI_DIR/startup.nsh
echo "$EFI_DIR\\$LINUX initrd=$EFI_DIR\\$INITRAMFS dtb=$EFI_DIR\\$DTB ignore_loglevel earlyprintk earlycon root=PARTUUID=abcd1234-04 rw rootwait console=tty0 cpuidle.off=1" >> $EFI_DIR/startup.nsh
echo 'reset -s' >> $EFI_DIR/startup.nsh

echo "All done ! Copy $BOOT_DIR to your boot partition or use its content to update your existing startup script."
