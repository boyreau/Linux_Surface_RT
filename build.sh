#!/bin/bash

# Useful variables
VERSION=$(make -s kernelrelease)

# Built files
LINUX=vmlinuz-$VERSION
DTB=tegra30-microsoft-surface-rt-efi.dtb
INITRAMFS=initramfs-$VERSION.img

# Relative and absolute boot partition pathes
BUILD_DIR=./output/boot
EFI_DIR=linux-$VERSION
LINUX_DIR=$BUILD_DIR/$EFI_DIR

if [ -z "$(which nproc 2>/dev/null)" ]
then
    MAXPROC=8
else
	MAXPROC=$(nproc)
fi

make ARCH=arm olddefconfig

echo "Recreating output"
rm -rf output
mkdir -p output

# Build kernel
# If this step fail, check that the CROSS-COMPILE option matches your compiler binary name - mine would be armv7l-unknown-linux-gnueabihf- ; yours is probably different
# This compiler should also be in your PATH. Careful, `which gcc` should give your original compiler (not a soft-link to the cross-compiler), and `which arm-linux-gnueabihf-gcc` should give your cross-compiler.
echo "Building kernel"
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j $MAXPROC || exit 1

echo "Copying kernel to ./output"
cp -v arch/arm/boot/zImage ./output/$LINUX
cp -v arch/arm/boot/dts/nvidia/$DTB ./output/$DTB

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
rm  -rf $LINUX_DIR
mkdir -p $LINUX_DIR

cp -v ./output/$LINUX        $LINUX_DIR/$LINUX
cp -v ./output/$DTB          $LINUX_DIR/$DTB
if [ -f ./output/$INITRAMFS ]
then
	cp -v ./output/$INITRAMFS    $LINUX_DIR/$INITRAMFS
fi

echo "Creating startup.nsh"
echo 'fs0:' > $BUILD_DIR/startup.nsh
echo -n "$EFI_DIR\\$LINUX " >> $BUILD_DIR/startup.nsh

if [ -f ./output/$INITRAMFS ]
then
	echo -n "initrd=$EFI_DIR\\$INITRAMFS " >> $BUILD_DIR/startup.nsh
fi

echo "dtb=$EFI_DIR\\$DTB ignore_loglevel earlyprintk earlycon root=PARTUUID=abcd1234-04 rw rootwait console=tty0 cpuidle.off=1" >> $BUILD_DIR/startup.nsh

echo 'reset -s' >> $BUILD_DIR/startup.nsh

echo "All done ! Copy $BUILD_DIR/$EFI_DIR content to your boot partition or use its content to update your existing startup script."
