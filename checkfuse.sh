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

# Прбуем найти модуль
KERNEL_RELEASE=`uname -r`
MODULEFUSE=`find /lib/modules/$KERNEL_RELEASE/ -name fuse.ko*`
if [ -z "$MODULEFUSE" ]; then
    MODULEFUSE=`find /lib/modules/$KERNEL_RELEASE/ -name fuse.o*`
fi

# Если modprobe не сработал, пробуем insmod
# при условии что модуль найден
LOADEDMODULE=`lsmod | grep fuse`
if [ -z "$LOADEDMODULE" ]; then
    if [ -n "$MODULEFUSE" ]; then
        /sbin/insmod $MODULEFUSE >> /dev/null 2>&1
    fi
fi

FUSE_DEV_CLEANUP=`cat $KSYMS | grep fuse_dev_cleanup`
if [ -n "$FUSE_DEV_CLEANUP" ]; then
    echo "FUSE Exist!"
    exit 0
fi

if [ -n "$MODULEFUSE" ]; then
    echo "Module $MODULEFUSE found. More research is needed!"
    exit 0
fi

echo "FUSE not found!!! More research is needed!"

