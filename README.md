# ardupilot_copter_bbblue

Ardupilot using Beaglebone Blue.

**This repo aims to easy the download of the ardupilot (copter) code to be used with beaglebone blue.**

Inspired from [Robert Nelson repos](https://github.com/rcn-ee/repos).

## Initial steps: BBBlue installation and pre-requisits

  * Download the latest [debian image](https://beagleboard.org/latest-images)
  
  * Uncompress it with the command:
    
    `$ unxz ~/Downloads/file.img.xz`
  
  * Format and write the image to the memory card (please check that you have the correct SD card device, in my case it is /dev/mmcblk0p1)
    
    `$ sudo dd if=~/Downloads/file.img of=/dev/mmcblk0p1`
    
    At this point you may want to resize the partition to the full SD card size. You can do it with [Gparted](https://gparted.org/). 
  
  * Start the beaglebone from the SD card and connect it to a wifi network:
  
    `$ connmanctl`
    
    `$ connmanctl > enable wifi `
    
    `$ connmanctl > scan wifi`
     
    `$ connmanctl > services`
    
    `$ connmanctl > agent on`
    
    `$ connmanctl > connect wifi_506583d4fc5e_544e434150413937414239_managed_psk `
    
    `$ Passphrase? xxxxxxxxxxx`
     
    `$ connmanctl > quit`
    
  * Update and install software:
  
    `$ sudo apt update && sudo apt upgrade -y`
    
    `$ sudo apt install -y bb-cape-overlays cpufrequtils`
    
  * Set clock to 1GHz:
  
    `$ sudo sed -i 's/GOVERNOR="ondemand"/GOVERNOR="performance"/g' /etc/init.d/cpufrequtils`
   
  * Add Blue DTB:
  
    `$ sudo sed -i 's/#dtb=$/dtb=am335x-boneblue-ArduPilot.dtb/' /boot/uEnv.txt`
  
  * Update scripts:
  
    `$ cd /opt/scripts && sudo git pull`
  
  * Install RT Kernel 4.4:
  
    `$ sudo /opt/scripts/tools/update_kernel.sh --ti-rt-channel --lts-4_4`
  
  * Restart beagleboneblue:
  
    `$ sudo shutdown -h now`

## ArduCopter: Cross compile with Ubuntu:

<!--#### Prerequisites-->

  <!--* Install compiler for ARM:-->

  <!--  `$ sudo apt-get install gcc-arm-linux-gnueabi`-->
  
#### Get the code

  `$ git clone https://github.com/angelsantamaria/ardupilot_copter_bbblue.git`

  `$ cd ardupilot_copter_bbblue`

  `$ ./generate_source.sh`

#### Cross compile it

  `$ cd ardupilot-copter-blue*`

  `$ ./Tools/scripts/install-prereqs-ubuntu.sh`

  `$ ./waf configure --board=blue`

  `$ ./waf`

#### Copy generated binary files to the beaglebone blue

  `$ scp build/blue/bin/* debian@beaglebone:~/ardupilot_bin/.`
 
  *Note that you may change the paths in the beaglebone blue depending on where you want the binary files.*

## Notes for future updates of Ardupilot or Beaglebone blue:

  * Check the version.sh script to verify that you are pointing to the last ardupilot (copter branch) repository.

  * If debian Jessie version is updated you have to update the suite folder. 

## Start automatically with beaglebone blue boot (as service) 

  * Create **in the beaglebone blue** the following file with your favorite editor (e.g. vim)

    `$ sudo vim /lib/systemd/system/ArduCopter.service`

    * Add the following lines to the file:

```
    [Unit]
    Description=ArduCopter Service
    After=bb-wl18xx-wlan0.service

    [Service]
    ExecStartPre=/bin/bash -c "/bin/echo uart > /sys/devices/platform/ocp/ocp:P9_21_pinmux/state"
    ExecStartPre=/bin/bash -c "/bin/echo uart > /sys/devices/platform/ocp/ocp:P9_22_pinmux/state"
    ExecStartPre=/bin/bash -c "/bin/echo uart > /sys/devices/platform/ocp/ocp:P9_24_pinmux/state"
    ExecStartPre=/bin/bash -c "/bin/echo uart > /sys/devices/platform/ocp/ocp:P9_26_pinmux/state"
    ExecStartPre=/bin/bash -c "/bin/echo pruecapin_pu > /sys/devices/platform/ocp/ocp:P8_15_pinmux/state"
    ExecStart=/home/debian/ardupilot_bin/arducopter -A udp:192.168.8.95:14550 -B /dev/tty05
    StandardOutput=null
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target
    Alias=Arducopter.service
```

  *Notice how the 5th [Service] line depends on your desired configuration*

  * Enable the new service

  `$ sudo systemctl enable ArduCopter.service`

  * Start the service
  
  `$ sudo systemctl start ArduCopter.service`

  * Reboot the beaglebone blue

  `$ sudo reboot`

  * To disable and stop the service in case you needed (e.g. to tune ESCs with the `rc_calibrate_escs` ardupilot must be switched off)

  `$ sudo systemctl disable ArduCopter.service`

  `$ sudo systemctl stop ArduCopter.service`

  `$ sudo shutdown -h now`
