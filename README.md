# Installing Linux on a Microsoft Surface RT

## Installing Linux

If you wish to install Linux on your Surface RT, I wrote an [installation guide](./INSTALL_DETAILED.md)

I plan to release some prebuilt linux images with installation script at some point.

If you wish to contribute and have a working Linux Image, feel free to send it to me, I'll happily share it here.

---
## History

This journey started when I received an old, mysterious "computer".

At first, I wasn't really interested in it:
 - a crappy windows version
 - awful performances and specifications
 - no application support
 - secure boot and no BIOS/UEFI interface to disable it

But at some point, I started looking into it and that was it.
I couldn't help but try to install Linux.

After some research, I stumbled upon a gitbook : Open Surface RT.
I had a starting point that provided a lot of informations.
There were exploits - Fusee Gelee, Golden Keys and Yahalo.

The first one is well-known: it cracked open the first nintendo switches.
Golden Keys is also kinda famous because it comes from a data breach in microsoft.
Yahalo is specific to the surface RT: it exploits a bug in the firmware to disable secure boot.

After applying Golden Keys and Yahalo exploits to my Surface, secure boot was finally off.
There was a prebuilt raspbian linux image on the gitbook, but I wasn't satisfied and the kernel sources were lost.
The kernel configuration also lacked some feature that I wanted, and wasn't up-to-date.
Sadly, the patches on the gitbook weren't enough to build a running kernel, and all the kernels I built crashed before leaving UEFI boot services.
Transfer wasn't even given to the kernel that it was already stuck.

I started playing around and learning about various topics:
 - EFI programming
 - Linux kernel sources (especially Linux EFI stub)
 - Device trees

At some point, I found the community behind the gitbook (almost or their discord links were dead)
Here, they had some information that really unblocked me:
 - a patched linux kernel repository
 - updated device tree
 - a default linux configuration

These felt like a miracle after weeks of research, trial and error.
But sadly all of this wasn't enough.

I took the raspbian prebuilt image that was working and merged its configuration with theirs.

I also had to patch the device tree since regulators were missing for the wifi and bluetooth nodes.

And at some point, after months of trial and error, it worked.
I had an up-to-date linux kernel, up and running.

After that, I started writing this guide to prevent others from giving up or wasting months searching.
