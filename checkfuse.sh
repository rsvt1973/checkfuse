#!/bin/bash


if [ -e /proc/ksyms ]; then
    KSYMS=/proc/ksyms
fi

if [ -e /proc/kallsyms ]; then
    KSYMS=/proc/kallsyms
fi


if [ -z "$KSYMS" ]; then
    echo "Kernel symbol table not found!!!"
    exit 1
fi

# Прбуем загрузить модуль, если он не в ядре
/sbin/modprobe fuse >> /dev/null 2>&1

FUSE_DEV_CLEANUP=`cat $KSYMS | grep fuse_dev_cleanup`

if [ -n "$FUSE_DEV_CLEANUP" ]; then
    echo "FUSE Exist!"
    exit 0
fi

# Прбуем найти модуль
KERNEL_RELEASE=`uname -r`
MODULEFUSE=`find /lib/modules/$KERNEL_RELEASE/ -name fuse.ko*`
if [ -n "$MODULEFUSE" ]; then
    echo "Module $MODULEFUSE found. More research is needed!"
    exit 0
fi

# Прбуем найти модуль
MODULEFUSE=`find /lib/modules/$KERNEL_RELEASE/ -name fuse.o*`
if [ -n "$MODULEFUSE" ]; then
    echo "Module $MODULEFUSE found. More research is needed!"
    exit 0
fi

echo "FUSE not found!!! More research is needed!"

