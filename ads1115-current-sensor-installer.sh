#!/bin/bash
#
#   █████╗ ██████╗ ███████╗ ██╗ ██╗ ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝███║███║███║██╔════╝
#  ███████║██║  ██║███████╗╚██║╚██║╚██║███████╗
#  ██╔══██║██║  ██║╚════██║ ██║ ██║ ██║╚════██║
#  ██║  ██║██████╔╝███████║ ██║ ██║ ██║███████║
#  ╚═╝  ╚═╝╚═════╝ ╚══════╝ ╚═╝ ╚═╝ ╚═╝╚══════╝
#
#   ██████╗██╗   ██╗██████╗ ██████╗ ███████╗███╗   ██╗████████╗
#  ██╔════╝██║   ██║██╔══██╗██╔══██╗██╔════╝████╗  ██║╚══██╔══╝
#  ██║     ██║   ██║██████╔╝██████╔╝█████╗  ██╔██╗ ██║   ██║   
#  ██║     ██║   ██║██╔══██╗██╔══██╗██╔══╝  ██║╚██╗██║   ██║   
#  ╚██████╗╚██████╔╝██║  ██║██║  ██║███████╗██║ ╚████║   ██║   
#   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   
#  
#  ███████╗███████╗███╗   ██╗███████╗ ██████╗ ██████╗ 
#  ██╔════╝██╔════╝████╗  ██║██╔════╝██╔═══██╗██╔══██╗
#  ███████╗█████╗  ██╔██╗ ██║███████╗██║   ██║██████╔╝
#  ╚════██║██╔══╝  ██║╚██╗██║╚════██║██║   ██║██╔══██╗
#  ███████║███████╗██║ ╚████║███████║╚██████╔╝██║  ██║
#  ╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
#
#  ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ 
#  ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
#  ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
#  ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
#  ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
#  ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
#
#  ads1115-current-sensor-installer v0.1
#  (c) 2021, Elias Thoma
#  This script provides an easy way to install everything needed to use the ads1115 from adafruit and ct-clamp's to
#  measure the current flowing in your electric house installation.
#  
#  To install the latest version of 'ads1115-current-sensor':
#       Run as root:  
#       curl -s https://raw.githubusercontent.com/ei1902/ads1115-current-sensor/master/ads1115-current-sensor-installer.sh | sudo bash
#

optstring=":h"

readonly url="http://github.com/et1902/ads1115-current-senor/archive/master.zip"

readonly tmp_dir="/var/tmp/ads1115-current-sensor-installer/"

usage()
{
    echo "Python current sensor installer."
    echo "./ads1115-current-sensor-installer.sh"
}

main()
{
    download_files()
    askYesNo "Enable MQTT?" false

    if [ "$ANSWER" = true ]; then
        read -p 'MQTT-Host: ' mqtt_host
        read -p 'MQTT-Topic: ' mqtt_topic
        read -p 'MQTT-Username: ' mqtt_username
        read -p 'MQTT-Password: ' mqtt_password       
        configure_mqtt(mqtt_host, mqtt_topic, mqtt_username, mqtt_password)
    fi

    setup_ads1115()

    # Final step: starting script
    systemctl start ads1115-current-sensor
}

download_files()
{
    echo "- downloading $url"
    wget -o"$tmp_dir/wget.txt" -NP "$tmp_dir" "$url"
}

setup_ads1115()
{
    echo "- installing necessary python libraries for ads1115"
    # Install required python libraries
    sudo pip3 install --upgrade adafruit-python-shell adafruit-circuitpython-ads1x15
    wget https://raw.githubusercontent.com/adafruit/Raspberry-Pi-Installer-Scripts/master/raspi-blinka.py
    sudo python3 raspi-blinka.py
}

setup_mqtt()
{
    # Install required python libraries
    sudo pip3 install paho-mqtt
}

configure_mqtt()
{

}

setup_api()
{
    # Install required python libraries
    sudo pip3 install requests

    #TODO: ask for api host and api key and subsitute those in script
}

install_service()
{
    echo "- installing ads-current-sensor.service"
    systemctl stop ads1115-current-sensor

    cp "$tmp_dir/ads1115-current-sensor.service" "/etc/systemd/system/ads1115-current-sensor.service"

    #TODO: ask if service should be automatically started at boot time
    systemctl enable ads1115-current-sensor
}

function askYesNo {
    QUESTION=$1
    DEFAULT=$2
    if [ "$DEFAULT" = true ]; then
            OPTIONS="[Y/n]"
            DEFAULT="y"
        else
            OPTIONS="[y/N]"
            DEFAULT="n"
    fi
    read -p "$QUESTION $OPTIONS " -n 1 -s -r INPUT
    INPUT=${INPUT:-${DEFAULT}}
    echo ${INPUT}
    if [[ "$INPUT" =~ ^[yY]$ ]]; then
        ANSWER=true
    else
        ANSWER=false
    fi
}

while getopts ${optstring} arg; do
  case ${arg} in
    h)
      usage
      ;;
    :)
      main
      ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      usage
      exit 2
      ;;
  esac
done

