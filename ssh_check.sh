#!/bin/bash

error() {
	printf '\E[31m'; echo "$@"; printf '\E[0m'
}
success() {
	printf '\E[32m'; echo "$@"; printf '\E[0m'
}

if [[ $EUID -ne 0 ]]; then
	error "[!]This script must be run as root"
	exit 1
fi

echo "[.]Grabbing OS version from os-release file..."
if [ -e /etc/os-release ]; then
	long_ver=$(grep "^ID=" /etc/os-release)
else
	long_ver=$(grep "^ID=" /usr/lib/os-release)	
fi

echo "[.]Determining OS version..."
if [[ $(echo $long_ver | grep kali) != "" ]]; then
	ver="kali"
	success "[+]Kali version found"
elif [[ $(echo $long_ver | grep opensuse) != "" ]]; then
	ver="opensuse"
	success "[+]OpenSUSE version found"
elif [[ $(echo $long_ver | grep centos) != "" ]]; then
	ver="centos"
	success "[+]CentOS version found"
fi

echo "[.]Finding failed SSH attempts..."
echo "-------------------------------------------------"
echo "Bad Guy IPs:"
if [[ $ver == "kali" ]]; then
        grep "Failed password" /var/log/auth.log|grep ssh|awk '{print "\t"$11}' | grep -v ';'|uniq
elif [[ $ver == "centos" ]]; then
        grep "Failed password" /var/log/secure|grep ssh|awk '{print "\t"$11}'|uniq
elif [[ $ver == "opensuse" ]]; then
	grep "Failed password" /var/log/messages|grep ssh|awk '{print "\t"$(NF-3)}'|uniq
fi
