#!/bin/bash

if [ -f /boot/startup.nsh.risky ]
then
	mv /boot/startup.nsh /boot/startup.nsh.bak
	mv /boot/startup.nsh.risky /boot/startup.nsh
fi
