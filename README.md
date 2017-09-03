# ardupilot_copter_bbblue

Ardupilot using Beaglebone Blue.

**This repo aims to easy the download of the ardupilot (copter) code to be used with beaglebone blue.**

Inspired from [Robert Nelson repos](https://github.com/rcn-ee/repos).

## Cross compile with Ubuntu:

<#### Prerequisites>

  <* Install compiler for ARM:>

    <`$ sudo apt-get install gcc-arm-linux-gnueabi`>

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

## Extra

#### Start automatically with beaglebone blue boot (as service) 

  * Create **in the beaglebone blue** the following file with your favorite editor (e.g. vim)

    `$ sudo vim /lib/systemd/system/ArduCopter.service`

    * Add the following lines to the file:

```
    [Unit]
    Description=ArduCopter Service
    After=bb-wl18xx-wlan0.service

    [Service]
    ExecStartPre=/bin/echo uart > /sys/devices/platform/ocp/ocp\:P9_21_pinmux/state
    ExecStartPre=/bin/echo uart > /sys/devices/platform/ocp/ocp\:P9_22_pinmux/state
    **ExecStart=/home/debian/bin/arducopter -A udp:192.168.8.127:14550**
    StandardOutput=null

    [Install]
    WantedBy=multi-user.target
    Alias=Arducopter.service
```

  *Notice how the bold line depends on your desired configuration*

  * Enable the new service

  `$ sudo systemctl enable ArduCopter.service`

  * Start the service
  
  `$ sudo systemctl start ArduCopter.service`

  * Reboot the beaglebone blue

  `$ sudo reboot`

  * To disable and stop the service in case you needed (e.g. to tune ESCs with the `rc_calibrate_escs` ardupilot must be switched off)

  `$ sudo systemctl disable ArduCopter.service`

  `$ sudo systemctl stop ArduCopter.service`

  `$ sudo reboot`
