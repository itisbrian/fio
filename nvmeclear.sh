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
echo -e " \e[5m                         SYSLAB Supreme NVME Wipe.\e[25m"
echo -e "\e[32m Code in Beta Test : report errors to brianchen@supermicro.com \e[0m"
echo " "

#################################################################################################
#color correction:
# \e[32m = green
# \e[31m = red
# \e[93m = Orange
# \e[0m = white


#################################################################################################
#detect  partitions in drives and deletes it

echo -e "============================== \e[33mDrive Detection\e[0m =============================="
echo " "
#DISKPARTS=`ls /dev/sd*[0-9] 2>/dev/null`
#if [ "${DISKPARTS}" != "" ]; then
#        for i in `ls /dev/sd* | grep -v '[0-9]$'`; do
#            echo "Partitions found on HDD/SSD disk:"
#            echo "${i}"
#            #wipefs -a $i 2>/dev/null
#            parted -s "$i" mklabel gpt
#            echo "HDD/SDD wipe finished."
        #echo "Deleting all partitions."
        #echo ""
        #nvme format -s 1 "${DISKPARTS}"
        #echo "NVME partitions deleted."
#        done
#fi

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
echo -e "======================================= \e[33mEnd\e[0m ======================================="
