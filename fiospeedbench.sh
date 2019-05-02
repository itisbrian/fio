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
JOBFILETARGET="${RDIR}/fiospeedbench.job"
OUTPUTFILETARGET="${RDIR}/fiospeedbench.out"

echo "" > "${JOBFILETARGET}"

JOBFILEHEADER="[global] ioengine=libaio runtime=30 iodepth=128 numjobs=1 time_based direct=1"

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
#color correction:
# \e[32m = green
# \e[31m = red
# \e[93m = Orange
# \e[0m = white
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


#################################################################################################
#detect  partitions in drives and deletes it

echo -e "============================== \e[33mDrive Detection\e[0m =============================="
echo " "
DISKPARTS=`ls /dev/sd*[0-9] 2>/dev/null`
if [ "${DISKPARTS}" != "" ]; then
        for i in `ls /dev/sd* | grep -v '[0-9]$'`; do
            echo "Partitions found on HDD/SSD disk:"
            echo "${i}"
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
#            echo "Nvme wipe finished."
#        fi
done


################################################################

#HDD Read 1m 2m
counter=0
for disk in `ls /dev/sd* 2>/dev/null`; do
        ####################################### 1m read ###########
        echo "[${disk}]" >> "${JOBFILETARGET}"
        echo "stonewall" >> "${JOBFILETARGET}"
        echo "filename=${disk}" >> "${JOBFILETARGET}"
        echo "bs=1m" >> "${JOBFILETARGET}"
        echo "rw=read" >> "${JOBFILETARGET}"
        echo "" >> "${JOBFILETARGET}"
        ####################################### 2m read ###########
        echo "[${disk}]" >> "${JOBFILETARGET}"
        echo "stonewall" >> "${JOBFILETARGET}"
        echo "filename=${disk}" >> "${JOBFILETARGET}"
        echo "bs=2m" >> "${JOBFILETARGET}"
        echo "rw=read" >> "${JOBFILETARGET}"
        echo "" >> "${JOBFILETARGET}"
        ########################### HDD 1m write ############
        echo "[${disk}]" >> "${JOBFILETARGET}"
        echo "stonewall" >> "${JOBFILETARGET}"
        echo "filename=${disk}" >> "${JOBFILETARGET}"
        echo "bs=1m" >> "${JOBFILETARGET}"
        echo "rw=write" >> "${JOBFILETARGET}"
        echo "" >> "${JOBFILETARGET}"
        ############################ HDD 2m write ##############
        echo "[${disk}]" >> "${JOBFILETARGET}"
        echo "stonewall" >> "${JOBFILETARGET}"
        echo "filename=${disk}" >> "${JOBFILETARGET}"
        echo "bs=2m" >> "${JOBFILETARGET}"
        echo "rw=write" >> "${JOBFILETARGET}"
        echo "" >> "${JOBFILETARGET}"
        let "counter=$counter+1"
done


        echo " "
        echo -e "\e[32m$counter\e[0m HDD/SSD found."
	hddcounter=$counter




################ NVME  ###################################################################

for disk in `ls /dev/nvme*n1 2>/dev/null`; do
        #JOBFILETARGETL="${JOBFILETARGET}_${disk}.fio"
        #OUTPUTFILETARGETL="${OUTPUTFILETARGET}_${disk}.fioperf"
        ###################nvme 1m read #######################
        echo "[${disk}]" >> "${JOBFILETARGET}"
        echo "stonewall" >> "${JOBFILETARGET}"
        TARGETNAME=`echo "${disk}" | cut -d'/' -f3`
        NUMA_TARGET=`cat /sys/block/${TARGETNAME}/device/device/numa_node`
        echo "numa_cpu_nodes=${NUMA_TARGET}" >> "${JOBFILETARGET}"
        echo "numa_mem_policy=bind:${NUMA_TARGET}" >> "${JOBFILETARGET}"
        echo "filename=${disk}" >> "${JOBFILETARGET}"
        echo "bs=1m" >> "${JOBFILETARGET}"
        echo "rw=read" >> "${JOBFILETARGET}"
        echo "numjobs=2" >> "${JOBFILETARGET}"
        echo "" >> "${JOBFILETARGET}"
        ###################nvme 2m read #######################
        echo "[${disk}]" >> "${JOBFILETARGET}"
        echo "stonewall" >> "${JOBFILETARGET}"
        TARGETNAME=`echo "${disk}" | cut -d'/' -f3`
        NUMA_TARGET=`cat /sys/block/${TARGETNAME}/device/device/numa_node`
        echo "numa_cpu_nodes=${NUMA_TARGET}" >> "${JOBFILETARGET}"
        echo "numa_mem_policy=bind:${NUMA_TARGET}" >> "${JOBFILETARGET}"
        echo "filename=${disk}" >> "${JOBFILETARGET}"
        echo "bs=2m" >> "${JOBFILETARGET}"
        echo "rw=read" >> "${JOBFILETARGET}"
        echo "numjobs=2" >> "${JOBFILETARGET}"
        echo "" >> "${JOBFILETARGET}"
        ###################nvme 1m write #######################
        echo "[${disk}]" >> "${JOBFILETARGET}"
        echo "stonewall" >> "${JOBFILETARGET}"
        TARGETNAME=`echo "${disk}" | cut -d'/' -f3`
        NUMA_TARGET=`cat /sys/block/${TARGETNAME}/device/device/numa_node`
        echo "numa_cpu_nodes=${NUMA_TARGET}" >> "${JOBFILETARGET}"
        echo "numa_mem_policy=bind:${NUMA_TARGET}" >> "${JOBFILETARGET}"
        echo "filename=${disk}" >> "${JOBFILETARGET}"
        echo "bs=1m" >> "${JOBFILETARGET}"
        echo "rw=write" >> "${JOBFILETARGET}"
        echo "numjobs=2" >> "${JOBFILETARGET}"
        echo "" >> "${JOBFILETARGET}"
        ###################nvme 2m write #######################
        echo "[${disk}]" >> "${JOBFILETARGET}"
        echo "stonewall" >> "${JOBFILETARGET}"
        TARGETNAME=`echo "${disk}" | cut -d'/' -f3`
        NUMA_TARGET=`cat /sys/block/${TARGETNAME}/device/device/numa_node`
        echo "numa_cpu_nodes=${NUMA_TARGET}" >> "${JOBFILETARGET}"
        echo "numa_mem_policy=bind:${NUMA_TARGET}" >> "${JOBFILETARGET}"
        echo "filename=${disk}" >> "${JOBFILETARGET}"
        echo "bs=2m" >> "${JOBFILETARGET}"
        echo "rw=write" >> "${JOBFILETARGET}"
        echo "numjobs=2" >> "${JOBFILETARGET}"
        echo "" >> "${JOBFILETARGET}"
       #/root/fio/fio "${JOBFILETARGET}" --output=$OUTPUTFILETARGET
        let "counter=$counter+1"

done
	nvmecounter=`expr $counter - $hddcounter`
	echo -e "\e[32m$nvmecounter\e[0m NVMe found."
    echo " "

if [ $counter -eq 0 ]; then
        echo -e "\e[31mNo disks found, bailing.\e[0m"
        exit 1
fi

############################# color correction ##################
green='tput setaf 2'
norm='tput sgr0'
############################# start fio #########################
echo -e "============================== \e[33mBenchmark Start\e[0m =============================="

let "st=$counter * 2"
echo " "
${green}
echo "Start Time     : $(date)"
echo "Completion ETA : $(date -d +${st}' minutes')"
${norm}
echo " "
#v='/root/fio-master/./fio -v'
echo "Running $(/root/SUPREMEFIO/./fio -v)."
/root/SUPREMEFIO/./fio "${JOBFILETARGET}" --output=$OUTPUTFILETARGET

cat "${RDIR}/fiospeedbench.out" | grep "(g=" | egrep -o '^[^:]+' >> A.txt
cat "${RDIR}/fiospeedbench.out" | grep bw= | egrep -o '^[^,]+' >> B.txt

echo " "
echo " "
echo -e "\e[32mSummary:\e[0m"
paste -d "" A.txt B.txt

echo -e " SYSLAB Bench Summary"  > ${RDIR}/fiosummary.txt
echo -e "============================================================================" &>> ${RDIR}/fiosummary.txt

echo -e " "  &>> ${RDIR}/fiosummary.txt

hostnamectl 2>/dev/null

if [ $? -ne 0 ]; then
    echo "Unable to obtain system information."

else
    hostnamectl &>>  ${RDIR}/fiosummary.txt
fi



cat /etc/redhat-release 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Unable to obtain release version."
else
    cat /etc/redhat-release &>> ${RDIR}/fiosummary.txt
fi

echo -e " "  &>> ${RDIR}/fiosummary.txt

paste -d "" A.txt B.txt >> ${RDIR}/fiosummary.txt
rm -f A.txt
rm -f B.txt

echo " "
echo " "
echo -e "\e[32mSpeed Bench Finished.\e[0m"
echo -e "\e[32mCheck fiospeedbench.out in the burnin directory for full results.\e[0m"
echo -e "\e[32mCheck fiospeedbenchsummary.txt in the burnin directory for short summary.\e[0m"
echo " "
echo -e "============================== \e[33mBenchmark End\e[0m ================================"

###############################################################
