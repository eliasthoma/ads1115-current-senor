# Installation of EmonCMS

1. Download offical EmonCmd Raspberry PI image

2. Burn the image to and sd-card (min. 12GB)

3. Enable SSH-Access

    Create a file called "ssh" on "boot". (no file extension!)

4. Configure WiFi

    Create a file "wpa_supplicant.conf" on "boot" with:
    '''
    country=DE
    trl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1

    network={
        ssid="your-ssid"
        psk="your-password"
    }
    '''

5. Create a User Account
    Open your Web-Browser and connect with emonpi.local or your Rapsp's ip-address
    Click and Register and create your first account.


https://askubuntu.com/questions/199565/not-enough-space-on-tmp

https://www.e-tinkers.com/2017/03/boot-raspberry-pi-with-wifi-on-first-boot/#:~:text=Boot%20Raspberry%20Pi%20with%20wifi%20on%20first%20boot,this%20allows%20your%20to%20...%20Weitere%20Artikel...

https://www.emqx.io/blog/how-to-use-mqtt-in-python

https://github.com/SBFspot/SBFspot/wiki/Installation-Linux-SQLite

https://guide.openenergymonitor.org/technical/credentials/#mqtt

# SBFspot installation and configuration

1. Open "/boot/config.txt" and remove "dtoverlay=pi3-disable-bt" and reboot.

2. Reinstall pi-bluetooth

    sudo apt-get purge pi-bluetooth
    sudo apt-get install pi-bluetooth

2. Enable bluetooth 

https://raspberrypi.stackexchange.com/questions/40839/sap-error-on-bluetooth-service-status

3. Increase size of /var/temp/
    
    sudo umount -l /var/tmp
    sudo mount -t tmpfs -o size=104857600,mode=1777 overflow /var/tmp

    Command "df" shows partitions and their size

4. Install SBFspot

    curl -s https://raw.githubusercontent.com/sbfspot/sbfspot-config/master/sbfspot-config | sudo bash
    In Config-Dialog select Connection->Bluetooth and select your SMA-Inverter(s)

5. MQTT Publishung 


# Current Sensor with ADS1115 and CT-Clamp

sudo apt install python3-pip

1. Install CircuitPython

    sudo pip3 install --upgrade adafruit-python-shell
    wget https://raw.githubusercontent.com/adafruit/Raspberry-Pi-Installer-Scripts/master/raspi-blinka.py
    sudo python3 raspi-blinka.py

    Accept, if you've been asked to update the default python installation to Version 3

2. Install ADS1x15 Library

    pip3 install adafruit-circuitpython-ads1x15

3. Install PAHO-MQTT Library

    pip3 install paho-mqtt

4. Download Python script to Raspberry Pi


5. Register new service

https://websofttechs.com/tutorials/how-to-setup-python-script-autorun-in-ubuntu-18-04/



https://www.digijunkies.de/raspberry-pi-3-mit-jessieuart-einstellen-nutzen-und-konfigurieren-43332