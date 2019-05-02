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
# This script replaces tty4 (alt+f5) with a console executing these two python programs
#
# Requirements are:
IP=westworld.bnet

echo " " |tee -a /dev/tty0

wget "http://${IP}/fio/getty-fio@.service" -O "/lib/systemd/system/getty-fio@.service" &> /dev/null
if [ $? -ne 0 ]
 then
	echo "Failed to acquire getty service for Fio." | tee /dev/tty0
	return 1
	exit 1
fi
echo "Fio Service installed." | tee /dev/tty0
############################################################################################################################
/usr/bin/systemctl daemon-reload
if [ $? -ne 0 ]
 then
	echo "Failed to reload systemd." | tee /dev/tty0
	return 2
#	exit 2
fi
echo "Systemd reload finished." | tee /dev/tty0
########################################################################################################################

wget "http://${IP}/fio/fiospeedbench.sh" -O "/usr/local/sbin/startfio.sh" &> /dev/null
if [ $? -ne 0 ]
 then
	echo "Failed to get Fio test." | tee /dev/tty0
	return 1
#	exit 1
fi
chmod +x /usr/local/sbin/startfio.sh

echo "Fio test installed." | tee /dev/tty0

###############################################################################################################################
mkdir /root/SUPREMEFIO
wget "http://${IP}/fio/fio" -O "/root/SUPREMEFIO/fio" &> /dev/null
wget "http://${IP}/fio/findnuma.sh" -O "/root/SUPREMEFIO/findnuma.sh" &> /dev/null
wget "http://${IP}/fio/nvme_test.job" -O "/root/SUPREMEFIO/nvme_test.job" &> /dev/null
wget "http://${IP}/fio/nvmeclear.sh" -O "/root/SUPREMEFIO/nvmeclear.sh" &> /dev/null

if [ $? -ne 0 ]
 then
	echo "Failed to get Fio package." | tee /dev/tty0
	return 1
#	exit 1
fi
chmod -R +x /root/SUPREMEFIO

echo "Fio package installed in /root/SUPREMEFIO." | tee /dev/tty0

/usr/bin/systemctl stop getty-auto-cburn@tty2.service
/usr/bin/systemctl stop getty-auto-root@tty2.service
/usr/bin/systemctl stop getty@tty2.service
echo " " |tee -a /dev/tty0
echo " " 
echo "Modifying bashrc." | tee /dev/tty0

echo "source /root/stage2.conf" >> /root/.bash_profile
echo 'if test -t 0; then' >> /root/.bash_profile
echo 'script -f "${SYS_DIR}"/tty"${XDG_VTNR}".txt' >> /root/.bash_profile
echo 'exit' >> /root/.bash_profile
echo "fi" >> /root/.bash_profile

systemctl restart getty-auto-root@tty10
systemctl restart getty-auto-root@tty11
systemctl restart getty-auto-root@tty12

echo -e "\e[32mLogger Started.\e[0m" | tee /dev/tty0
echo -e "\e[32mStarting Fio. View Progress in Alt+F2\e[0m" |tee -a /dev/tty0
echo " " |tee -a /dev/tty0
/usr/bin/systemctl start getty-fio@tty2.service

#echo "Waiting for completion of FIO" | tee -a /dev/tty0
#sleep 86400
#echo "FIO Test Finished" | tee -a /dev/tty0
