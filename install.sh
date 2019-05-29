#!/usr/bin/env bash

declare CURR_VER=0.1.5.13
declare -a MK_VERS=(`ls /usr/src | grep mk_arcade_joystick_rpi | sort -n -r | cut -d '-' -f 2`)

sudo modprobe -r mk_arcade_joystick_rpi

for MK_VER_NUM in "${MK_VERS[@]}"; do
	sudo dkms remove -m mk_arcade_joystick_rpi -v $MK_VER_NUM --all
	sudo rm -rf /usr/src/mk_arcade_joystick_rpi-$MK_VER_NUM
done

sudo mkdir /usr/src/mk_arcade_joystick_rpi-$CURR_VER
sudo cp -a * /usr/src/mk_arcade_joystick_rpi-$CURR_VER/
sudo apt-get install -y --force-yes dkms cpp-4.7 gcc-4.7 joystick raspberrypi-kernel raspberrypi-kernel-headers wiringpi libpthread-stubs0-dev 
echo If your kernel was just updated, you may need to reboot and rerun this script
sudo dkms build -m mk_arcade_joystick_rpi -v $CURR_VER
sudo dkms install -m mk_arcade_joystick_rpi -v $CURR_VER --force

echo ""
if grep -q mk_arcade_joystick_rpi /etc/modules; then
	echo "mk_arcade_joystick_rpi already present in /etc/modules"
	echo "You may need to edit /etc/modules by hand"
else
	sudo sh -c 'echo "mk_arcade_joystick_rpi" >> /etc/modules'
fi
echo ""

if [ -e /etc/modprobe.d/mk_arcade_joystick.conf ] && grep -q -e "^options mk_arcade_joystick_rpi" /etc/modprobe.d/mk_arcade_joystick.conf ; then
	echo "/etc/modprobe.d/mk_arcade_joystick.conf exists and contains options for mk_arcade_joystick_rpi"

	if grep -q -e "v0.1.5.10" /etc/modprobe.d/mk_arcade_joystick.conf ; then
		echo "Already contain lines for v0.1.5.10+ of the driver"
	else
		echo "Adding lines for v0.1.5.10+ of the driver"
		sudo sh -c 'echo "" >> /etc/modprobe.d/mk_arcade_joystick.conf'
		sudo sh -c 'echo "##### Options below this line are for v0.1.5.10+ of the driver.  Options above this may not function." >> /etc/modprobe.d/mk_arcade_joystick.conf'
		sudo sh -c 'echo "#options mk_arcade_joystick_rpi map=4 gpio=4,17,6,5,19,26,16,24,23,18,15,14,-20,-1,-1,-1,-1,-1,-1,-1,-1 hkmode=2" >> /etc/modprobe.d/mk_arcade_joystick.conf'
	fi

else
	sudo sh -c 'echo "" >> /etc/modprobe.d/mk_arcade_joystick.conf'
	sudo sh -c 'echo "##### Options below this line are for v0.1.5.10+ of the driver.  Options above this may not function." >> /etc/modprobe.d/mk_arcade_joystick.conf'
	sudo sh -c 'echo "#U,D,L,R BTN_START, BTN_SELECT, BTN_A, BTN_B, BTN_TR, BTN_Y, BTN_X, BTN_TL, BTN_MODE, BTN_TL2, BTN_TR2, BTN_C, BTN_Z"'
	sudo sh -c 'echo "options mk_arcade_joystick_rpi map=4 gpio=4,17,6,5,19,26,16,24,23,18,15,14,-20,-1,-1,-1,-1,-1,-1,-1,-1 hkmode=2" >> /etc/modprobe.d/mk_arcade_joystick.conf'
	sudo sh -c 'echo "#this next line is for use with 4 extra buttons (maybe L2,R2,C,Z)" >> /etc/modprobe.d/mk_arcade_joystick.conf'
	sudo sh -c 'echo "#options mk_arcade_joystick_rpi map=4 gpio=4,17,6,5,19,26,16,24,23,18,15,14,-20,42,43,41,40,-1,-1,-1,-1 hkmode=2" >> /etc/modprobe.d/mk_arcade_joystick.conf'
	sudo sh -c 'echo "#this next line is for use with a single PSP1000 analog stick" >> /etc/modprobe.d/mk_arcade_joystick.conf'
	sudo sh -c 'echo "#options mk_arcade_joystick_rpi map=4 hkmode=2 i2cbus=1 x1addr=72 y1addr=77 gpio=4,17,6,5,19,26,16,24,23,18,15,14,-20,42,43,-1,41,-1,-1,-1,-1" >> /etc/modprobe.d/mk_arcade_joystick.conf'
	sudo sh -c 'echo "#this next line is for use with 2 PSP1000 analog sticks" >> /etc/modprobe.d/mk_arcade_joystick.conf'
	sudo sh -c 'echo "#options mk_arcade_joystick_rpi map=4 hkmode=2 i2cbus=1 x1addr=72 y1addr=77 x2addr=75 y2addr=79 gpio=4,17,6,5,19,26,16,24,23,18,15,14,-20,42,43,-1,41,-1,-1,-1,-1" >> /etc/modprobe.d/mk_arcade_joystick.conf'
	sudo sh -c 'echo "#this next line is an example for use with 8 extra buttons (maybe L2,R2,C,Z,TOP,TOP2,BASE,BASE2)" >> /etc/modprobe.d/mk_arcade_joystick.conf'
	sudo sh -c 'echo "#options mk_arcade_joystick_rpi map=4 gpio=4,17,6,5,19,26,16,24,23,18,15,14,-20,42,43,41,40,35,36,37,38 hkmode=2" >> /etc/modprobe.d/mk_arcade_joystick.conf'
	sudo sh -c 'echo "#this next line is for use with a single PSP1000 analog stick using min/max/fuzz/flat parameters" >> /etc/modprobe.d/mk_arcade_joystick.conf'
	sudo sh -c 'echo "#options mk_arcade_joystick_rpi map=4 hkmode=2 i2cbus=1 x1addr=72 y1addr=77 x1params=374,3418,16,384 y1params=517,3378,16,384 gpio=4,17,6,5,19,26,16,24,23,18,15,14,-20,42,43,-1,41,-1,-1,-1,-1" >> /etc/modprobe.d/mk_arcade_joystick.conf'
fi

echo ""

sudo modprobe mk_arcade_joystick_rpi

printf "Compiling mk_joystick_config : "
sudo g++ mk_joystick_config.cpp -o mk_joystick_config -lpthread -lwiringPi
if [ -e mk_joystick_config ]; then
	echo "Success."
	
	sudo cp retropiemenu/mk_joystick_config.png /home/pi/RetroPie/retropiemenu/icons/mk_joystick_config.png
	sudo cp retropiemenu/mk_joystick_config.sh /home/pi/RetroPie/retropiemenu/mk_joystick_config.sh
		
	if grep -q -e "mk_joystick_config.sh" /opt/retropie/configs/all/emulationstation/gamelists/retropie/gamelist.xml ; then
		echo "Retropie gamelist.xml already contain mk_joystick_config item"
	else
		echo "Adding mk_joystick_config item to Retropie gamelist.xml"
		sudo sed -i 's|</gameList>|\t<game>\n\t\t<path>./mk_joystick_config.sh</path>\n\t\t<name>Freeplay GPIO Driver Configurator</name>\n\t\t<desc>Allow end user to create its own GPIO driver configuration.</desc>\n\t\t<image>./icons/mk_joystick_config.png</image>\n\t</game>\n</gameList>|' /opt/retropie/configs/all/emulationstation/gamelists/retropie/gamelist.xml
	fi
	
else
	echo "Failed."
fi
echo ""

echo "It is recommended that you run 'sudo nano /etc/modprobe.d/mk_arcade_joystick.conf' to set up desired parameters."
