# Linux installation guide on Microsoft Surface RT

## Introduction

Installing Linux on a Surface RT was a long and arduous journey.
I'dd like to share my experiences and make it easier for whoever may come next.

Surface RT 1 and 2 are a real pain since they come with an ARM processor. Most CPUs are x86\_64.
ARM is like a language that the processor is speaking. If you give traditionnal x86 programs to an ARM processor, it will not be able to read or execute it.

Most Linux distributions do not offer support nor prebuilt kernel/binaries for ARM, and even when they do, they do not support Surface RT devices.

This process is somewhat complicated because there are no Linux distribution providers/maintainers.
You have to piece multiple softwares together, maintain them up to date and ensure they stay compatible.

But fear not, this guide will give you detailed steps and utilities to achieve your goals.

---
## Glossary

Kernel: The complex mechanisms in your car. You do not see them, but you do need them.

Userspace: The steering wheel, gearshift and pedals of your car. What you interract with to get your computer to doing something.

Initramfs: The keys of your car (required to **start** it).

Note: I do not like cars.

---
## Steps required :
 - Select a distribution
   - Build your kernel
   - Select a userspace
 - Optionnal: build an initial ramdisk
 - Set up an installation medium
 - Boot from your installation medium
 - Copy your freshly-built Linux to your device

It may sound like a lot, but these are baby steps.

---
## Select a distribution

To run specific programs (your userspace), you need specific kernel configuration options. Distribution maintainer are willing to do this initial configuration.
This means Ubuntu default kernel configuration should be good enough to run most APT packages.

### Build your kernel

I recommend building the kernel directly on the Surface RT (on the prebuilt Raspberry Pi OS image or equivalent).
You don't need to set-up cross-compilation and it will help you building a functional config file for the kernel.

#### The kernel sources

First thing first, you need the kernel sources (cloning may take a while, keep reading).

```bash
# Remove `--depth 1 --single-branch` if you want the full history - it's gonna take a lot of time and disk space
git clone --depth 1 --single-branch --branch master https://gitlab.com/clamor-s/linux ~/linux
cd ~/linux
```

This repository is maintained by Clamor (https://gitlab.com/clamor-s/linux).
I use the master branch for my builds.

#### The kernel configuration file

Then, you need a valid kernel configuration file. It should contain your distribution configuration options AND Surface RT configurations options.

You have to find your favorite distro's kernel config. You may be able to find it in your distro's official repositories (look for a package named Linux).

If you're lucky, and running a Linux distribution right now, you can use `zcat /proc/config.gz` or `cat /boot/config$(uname -r)` to obtain your current configuration.

Then, you need to merge this configuration file with surface RT default working configuration.
You can find this configuration file [here](https://gitlab.com/clamor-s/linux/), in `arch/arm/configs/grate_defconfig`.

Note: this configuration did not work with my latest test, here's [mine](./.config)


This config is a merge of grate\_defconfig and of [this Surface RT linux installation](https://openrt.gitbook.io/open-surfacert/surface-rt/linux/kernel/prebuilt-binaries) (obtained through `zcat /proc/config.gz`).


The final step is to merge both configuration files using the following rule :
 - everything enabled in any of the configuration file should be kept 
 - everything enabled as built-in in one file should be kept built-in in the final file
 - no option should be duplicated

You can use this [script](./config_merge.sh).

```bash
./config_merge .config.surface_rt .config.distribution .config
```
The first argument is the default configuration, the second argument is the configuration file of your distribution and the third argument is the name of the merged configuration file (defaults to .config).

Name the merged configuration file `.config` and put it at the root of the previously cloned linux repository.

You can then use the [build.sh](./build.sh) script at the root of the repository.

You WILL need a [cross-compiler](https://stackoverflow.com/questions/897289/what-is-cross-compilation) for arm32 CPUs if you are not on your Surface RT.

I used [ARM prebuilt GNU/Linux armv7l-none-linux-gnueabihf for x86\_64 hosts cross-compiler](https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-linux-gnueabihf.tar.xz).

I had to remove the non-prefixed soft-link from the bin directory (x-tools/armv7l-unknown-linux-gnueabihf/bin/gcc...), and to add `DOWNLOAD_DIR/x-tools/armv7l-unknown-linux-gnueabihf/bin` in my PATH.

I also changed the CROSS\_COMPILE argument in build.sh to match the prefix (armv7l-unknown-linux-gnueabihf-) of the tools I just downloaded, instead of the generic arm-linux-gnueabihf- prefix.

```bash
cd ~/linux
build.sh
```

### Get your userspace

We need an ARM-compatible *userspace*.
It's a collection of prebuilt programs for the ARM architecture.
Most distribution target x86, but some of them provide ARM-compatible software as well.

---
##### Arch
You can find the arch linux arm userspace on archlinuxarm.org:

https://archlinuxarm.org/about/downloads

I use the ARMv7 Multi-platform

---
##### Ubuntu
You can use the Preinstalled server image for Raspberry Pi Generic (Hard-Float).

DO NOT TAKE THE 64-bit ARM version, Surface have 32-bit CPUs.

https://cdimage.ubuntu.com/releases/22.04/release/

This is a full iso, containing a kernel (not compatible with Surface RT) a ramdisk and a userspace.

You need to extract the userspace in a separate file.

TODO Instruction to extract Ubuntu userspace.
```bash
mount -o loop ./<ubuntu-image>.iso /mnt/ubuntu-disk
```

---

Now, you should have a kernel and a userspace

---
## Build an initial ramdisk

This part is required with some complex features like full-disk-encryption or RAID.
I may cover it later if there's a real need that emerges.

---
## Set up an installation medium

You will need an USB stick for this part.
You should save everything on the USB because we will wipe it.

### Building your own .img/.iso

First, you need an empty, large-enough image disk file.

```bash
bash@computer$ # Create a 16G-wide linux.img file.
bash@computer$ truncate -s 16G linux.img
bash@computer$ 
```

Now, you need to make it a real disk image using fdisk

```bash
bash@computer$ # Format it as a disk
bash@computer$ fdisk linux.img

Welcome to fdisk (util-linux 2.41).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS (MBR) disklabel with disk identifier 0x36f9191b.

(ins)Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
(ins)Select (default p): p
(ins)Partition number (1-4, default 1): 1
(ins)First sector (2048-33554431, default 2048):
(ins)Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-33554431, default 33554431): +512M

Created a new partition 1 of type 'Linux' and of size 512 MiB.

(ins)Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
(ins)Select (default p): p
(ins)Partition number (2-4, default 2): 2
(ins)First sector (1050624-33554431, default 1050624):
(ins)Last sector, +/-sectors or +/-size{K,M,G,T,P} (1050624-33554431, default 33554431):

Created a new partition 2 of type 'Linux' and of size 15.5 GiB.

(ins)Command (m for help): w
The partition table has been altered.
bash@computer$ 
```

You have to format your partitions to FAT32 and EXT4

```bash
sudo losetup -Pf ./linux.img # This makes your file appear as a virtual disk
mkfs.fat -F 32 /dev/loop0p1
mkfs.ext4 /dev/loop0p2
```

This image disk needs to be mounted on your filesystem.

```bash
sudo mount --mkdir /dev/loop0p1 /mnt/linux-boot
sudo mount --mkdir /dev/loop0p2 /mnt/linux-userspace
```

`/mnt/linux-boot` will contain boot informations.

`/mnt/linux-userspace` will contain your userspace and your kernel modules.

We're close to done here so bear with me a little more !

### The boot partition

Now that you have a valid and accessible image disk, you need to provide some basic utilies:
 - an EFI bootloader
 - a configuration file for your bootloader
 - your kernel
 - a devicetree
 - optional: your kernel configuration file

You can find a prebuilt boot partition file [here](./boot.tar.gz). You will need to add your kernel, config and dtb into it.

```bash
sudo blkid
cd ~/linux
export LINUX_DIR=/mnt/linux-boot/linux-$(make -s kernelrelease)
tar --extract --file ./boot.tar.gz --directory /mnt/linux-boot/
mkdir -p $LINUX_DIR
cp ~/linux/output/boot/startup.nsh /mnt/linux-boot/startup.nsh
cp -r ~/linux/output/boot/linux-$(make -s kernelrelease)  $LINUX_DIR/
cp ~/linux/.config           $LINUX_DIR/
unset LINUX_DIR
export ROOT_UUID=$(blkid | grep loop0p2 | cut -d'=' -f5 | tr -d '"')
sed -i "s/PARTUUID=\([A-Za-z0-9\-]*\)/PARTUUID=$ROOT_UUID/g" /mnt/linux-boot/startup.nsh
```

You should have a working boot partition.

### Userspace partition

This one should be pretty easy, you just need to copy everything in the downloaded userspace to `/mnt/linux-userspace`.
You also have to copy the kernel modules in your userspace.

```bash
cp <your userspace> /mnt/linux-userspace
cp -r ~/linux/output/lib /mnt/linux-userspace/lib
```
---

Now that your partitions are set up, the final step is to umount/close everything and to copy your .img on your USB stick.

```bash
umount /mnt/linux-boot
umount /mnt/linux-userspace
losetup -d /dev/loop0
```

And to finally write your img file on your usb stick

BEWARE OF DD MISUSE, I AM NOT RESPONSIBLE IF YOU OVERWRITE YOUR CURRENT LINUX INSTALLATION.
MAKE SURE TO REPLACE `/dev/sdX` with your USB stick device.
```bash
dd if=./linux.img of=/dev/sdX status=progress
```
This command can take a while with big userspace.

## Boot from your installation medium

You can now plug your USB stick in your Surface, hold volume down and press power. Release volume down when the surface logo appears.
Your linux should boot.

## Copy your installation medium to your device

If you want to boot your surface without the USB stick, you can do the following command on the surface:

AGAIN, BEWARE OF DD MISUSE. /dev/sdX should be your USB stick, and /dev/mmcblk is your internal memory.
Back up your surface data if you don't want to lose it.

```bash
dd if=/dev/sdX of=/dev/mmcblk0 status=progress
```

Shut down, unplug the USB stick and boot. Things should work.
