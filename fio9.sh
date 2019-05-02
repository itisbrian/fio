#!/bin/bash


#############################################################
#   _______     _______ _               ____
#  / ____\ \   / / ____| |        /\   |  _ \
# | (___  \ \_/ / (___ | |       /  \  | |_) |
#  \___ \  \   / \___ \| |      / /\ \ |  _ <
#  ____) |  | |  ____) | |____ / ____ \| |_) |
# |_____/   |_| |_____/|______/_/    \_\____/


#   _____ _    _ _____  _____  ______ __  __ ______
#  / ____| |  | |  __ \|  __ \|  ____|  \/  |  ____|
# | (___ | |  | | |__) | |__) | |__  | \  / | |__
#  \___ \| |  | |  ___/|  _  /|  __| | |\/| |  __|
#  ____) | |__| | |    | | \ \| |____| |  | | |____
# |_____/ \____/|_|    |_|  \_\______|_|  |_|______|





#####################################################################















# This script gets executed on tty2
#
# As a note, we need some way to pass sigusr1 to the endlogging script for immediate shutdown
#
# This rolls out a 1M blocksize for spinning disks.  Different disk classes will require new parameters.
#
cat /root/stage2.conf | grep "SYS_DIR" > /root/flasher_config.sh
source /root/flasher_config.sh

RDIR="${SYS_DIR}"
JOBFILETARGET="${RDIR}/fiostress.fiojob"
OUTPUTFILETARGET="${RDIR}/fiostress.out"


echo "" > "${JOBFILETARGET}"

JOBFILEHEADER="[global] ioengine=libaio runtime=999999999 iodepth=32 time_based direct=1"

for x in $JOBFILEHEADER; do
        echo "$x" >> "${JOBFILETARGET}"
done

echo "" >> "${JOBFILETARGET}"
################################################ SUPREME ###############################
echo ""
echo ""
echo -e "           \e[32m███████\e[0m╗\e[32m██\e[0m╗   \e[32m██\e[0m╗\e[32m███████\e[0m╗\e[32m██\e[0m╗      \e[32m█████\e[0m╗ \e[32m██████\e[0m╗ "
echo -e "           \e[32m██\e[0m╔════╝╚\e[32m██\e[0m╗ \e[32m██\e[0m╔╝\e[32m██\e[0m╔════╝\e[32m██\e[0m║     \e[32m██\e[0m╔══\e[32m██\e[0m╗\e[32m██\e[0m╔══\e[32m██\e[0m╗"
echo -e "           \e[32m███████\e[0m╗ ╚\e[32m████\e[0m╔╝ \e[32m███████\e[0m╗\e[32m██\e[0m║     \e[32m███████\e[0m║\e[32m██████\e[0m╔╝"
echo -e "           ╚════\e[32m██\e[0m║  ╚\e[32m██\e[0m╔╝  ╚════\e[32m██\e[0m║\e[32m██\e[0m║     \e[32m██\e[0m╔══\e[32m██\e[0m║\e[32m██\e[0m╔══\e[32m██\e[0m╗"
echo -e "           \e[32m███████\e[0m║   \e[32m██\e[0m║   \e[32m███████\e[0m║\e[32m███████\e[0m╗\e[32m██\e[0m║  \e[32m██\e[0m║\e[32m██████\e[0m╔╝"
echo -e "           ╚══════╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝╚═════╝ "
echo " "
echo -e " \e[5m                         SYSLAB Supreme HDD Test.\e[25m"
echo -e "\e[32m Report errors to brianchen@supermicro.com \e[0m"
echo " "





#################################################################################################
#numa node memory check

function memorycheck (){

echo -e "============================== \e[33mNuma Node Memory Check\e[0m =============================="
echo " "
memcounter=0
NC=`ls /sys/bus/node/devices | grep -Eo '[0-9]'`
for m in $NC; do
    NM=`cat /sys/bus/node/devices/node"${m}"/meminfo | grep "MemTotal:" | sed 's/^.*://' | awk '{ print $1 }'`

    for i in $NM; do
        if [[ $i -eq 0 ]]; then
         echo -e "Node $m has \e[31m$i\e[0m memory"
         ((memcounter+=1))
        fi
    done

done

if [[ $memcounter -gt 0 ]]; then
    echo ""    
    echo -e "\e[31mNode memory not allocated properly, please populate additional primary DIMM slots and try again.\e[0m"
    echo -e "\e[31mExiting FIO.\e[0m"
    echo ""
    exit 1
else 
    echo "Memory Checked Passed."
    echo " "
fi

}

checknvme=`lsblk | grep -i nvme | wc -l`
if [[ $checknvme -gt 0 ]]; then

memorycheck

else
:
fi


echo -e "============================== \e[33mDrive Detection\e[0m =============================="
#detect  partitions in drives and deletes it
echo " "
DISKPARTS=`ls /dev/sd*[0-9] 2>/dev/null`
if [ "${DISKPARTS}" != "" ]; then
        for i in `ls /dev/sd* | grep -v '[0-9]$'`; do
            echo "Partitions found on HDD/SSD disk:"

            #wipefs -a $i 2>/dev/null
            parted -s "$i" mklabel gpt
            echo "HDD/SDD wipe finished."
        #echo "Deleting all partitions."
        #echo ""
        #nvme format -s 1 "${DISKPARTS}"
        #echo "NVME partitions deleted."
        done
fi

DISKPARTS=`ls /dev/nvme*n1 2>/dev/null`
for x in $DISKPARTS; do
       echo "Secure erase" $x "."
       nvme format -s 1 "$x"
       echo "Secure erase finished."
#        d=`ls ${x}p* 2>/dev/null`
#        if [[ $d != "" ]]; then
#            echo $x " has partitions"
#            parted -s "$x" mklabel gpt
#            echo "NVMe wipe finished."
#        fi
done

################# Calculation Numjobs #################################################

hddcounter=`ls /dev/sd* 2>/dev/null | wc -l `
if [ $? -ne 0 ]; then
  hddcounter=0
fi
nvmecounter=`ls /dev/nvme*n1 2>/dev/null | wc -l `
if [ $? -ne 0 ]; then
  nvmecounter=0
fi

if [[ $hddcounter -eq 0 && $nvmecounter -eq 0 ]]; then
        echo "No disks found, bailing."
        exit 1
fi

cpucount=`grep -c ^processor /proc/cpuinfo`
nvmejob=$(expr $nvmecounter \* 8)
total=$(($hddcounter+$nvmejob))
numjob=8

if [ $cpucount -lt $total ]; then
        numjob=$((($cpucount-$hddcounter)/($nvmecounter)))

fi
if [ $numjob -lt 1 ]; then
        numjob=1
fi

################# HDD/SSD #############################################################

for disk in `ls /dev/sd* 2>/dev/null`; do
        echo "[${disk}]" >> "${JOBFILETARGET}"
        echo "filename=${disk}" >> "${JOBFILETARGET}"
        echo "rw=randrw" >> "${JOBFILETARGET}"
        echo "numjobs=1" >> "${JOBFILETARGET}"
        echo "" >> "${JOBFILETARGET}"

done
        echo " "
        echo -e "\e[32m$hddcounter\e[0m HDD/SSD found."

################ NVME  ###################################################################

for disk in `ls /dev/nvme*n1 2>/dev/null`; do
        #JOBFILETARGETL="${JOBFILETARGET}_${disk}.fio"
        #OUTPUTFILETARGETL="${OUTPUTFILETARGET}_${disk}.fioperf"

        echo "[${disk}]" >> "${JOBFILETARGET}"

        TARGETNAME=`echo "${disk}" | cut -d'/' -f3`
        NUMA_TARGET=`cat /sys/block/${TARGETNAME}/device/device/numa_node`
        echo "numa_cpu_nodes=${NUMA_TARGET}" >> "${JOBFILETARGET}"
        echo "numa_mem_policy=bind:${NUMA_TARGET}" >> "${JOBFILETARGET}"
        echo "filename=${disk}" >> "${JOBFILETARGET}"
        echo "rw=randrw" >> "${JOBFILETARGET}"
        echo "numjobs="$numjob >> "${JOBFILETARGET}"
        echo "" >> "${JOBFILETARGET}"


done

  echo -e "\e[32m$nvmecounter\e[0m NVMe found."
  echo " "
############################# color correction ##################
green='tput setaf 2'
norm='tput sgr0'
############################# start fio #########################
echo -e "============================== \e[33mStress Start\e[0m ================================="

#let "st=10080"
echo " "
${green}
echo "Start Time     : $(date)"
#echo "Completion ETA : $(date -d +${st}' minutes')"
echo "Control + C to stop stress testing."
${norm}
echo " "
echo "Thread Count     : " $cpucount
echo "Total Job Count  : " $total
echo "Max Nvme numjobs : " $numjob

#v='/root/fio-master/./fio -v'
echo "Running:  $(/root/SUPREMEFIO/./fio -v)."
echo " "


#/root/fio/fio-master/./fio -v
/root/SUPREMEFIO/./fio "${JOBFILETARGET}" --output=$OUTPUTFILETARGET

echo " "
echo " "
echo -e "\e[32mStress Stop / Interupt Time : $(date).\e[0m"
echo -e "\e[32mCheck fiostress.out in the burnin directory for results.\e[0m"
echo " "
echo -e "============================== \e[33mStress End\e[0m ==================================="
###############################################################
