#!/bin/bash

ARC=$(uname -a | sed "s/PREEMPT_DYNAMIC //g")

CPU=$(lscpu | grep "Socket(s):" | awk '{print $2}')

VCPU=$(nproc)

RAM=$(free -h | awk 'NR==2{print $2}' | sed "s/Mi//g" | awk '{print int($1 * 1.04858)}')
URAM=$(free -h | awk 'NR==2{print $3}' | sed "s/Mi//g" | awk '{print int($1 * 1.04858)}')
PRAM=$(bc <<< "scale=2; (100*$URAM/$RAM)")

DISK=$(df -h --total | awk '$1 == "total"{print $2}' | sed "s/G//g" | awk '{printf "%.2f", $1}')
DISKGB=$(printf "%.2f" $(echo "$DISK * 1.07374" | bc))
UDISK=$(df -h --total | awk '$1 == "total"{print $3}' | sed "s/G//g" | awk '{printf "%.2f", $1}')
UDISKGB=$(printf "%.2f" $(echo "$UDISK * 1.07374" | bc))
PDISK=$(df -h --total | awk '$1 == "total"{print $5}')

LOAD=$(top -bn1 | awk 'NR>7 { sum += $9 } END {printf "%.1f", sum}')

BOOT=$(who -b | awk '{print $3, $4}')

if [ "$(lsblk | grep "lvm" | awk '{print $1}')" ] ; then
LVM=yes
else
LVM=no
fi

CONNECT=$(netstat -an | grep -c ESTABLISHED)

USER=$(who | awk '{print $1}' | sort -u | wc -l)

IP=$(hostname -I)
MAC=$(ip a | grep "link/ether" | awk '{print $2}')

SUDO=$(journalctl | grep "sudo" | grep "COMMAND" | wc -l)

wall_message=" #Architecture: $ARC
#CPU physical : $CPU
#vCPU : $VCPU
#Memory Usage: $URAM/${RAM}MB ($PRAM%)
#Disk Usage: $UDISKGB/${DISKGB}Gb ($PDISK)
#CPU load: $LOAD%
#Last boot: $BOOT
#LVM use: $LVM
#Connections TCP : $CONNECT ESTABLISHED
#User log: $USER
#Network: IP $IP ($MAC)
#Sudo : $SUDO cmd"

wall -n "$wall_message"