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
#  measure the current in flowing in your electric house installation.
#  
#  To install the latest version of 'ads1115-current-sensor':
#       Run as root:  
#       curl -s https://raw.githubusercontent.com/sbfspot/sbfspot-config/master/sbfspot-config | sudo bash
#
#
#
#
#
#

optstring=":h"

readonly url_master="http://github.com/et1902/ads1115-current-sensor"

function usage
{
    echo "Python current sensor installer."
    echo "./install.sh"
}

function main
{
    setup_ads1115()

    #TODO: ask for intervall

    # Final step: starting to script
    systemctl start ads1115-current-sensor
}

function download_files
{
    echo "Downloading $url_releases/download/V$install_release/$targz"
    wget -o"$tmp_dir/wget.txt" -NP "$tmp_dir" "$url_releases/download/V$install_release/$targz"
}

function setup_ads1115
{
    # Install required python libraries
    sudo pip3 install --upgrade adafruit-python-shell adafruit-circuitpython-ads1x15
    wget https://raw.githubusercontent.com/adafruit/Raspberry-Pi-Installer-Scripts/master/raspi-blinka.py
    sudo python3 raspi-blinka.py
}

function setup_mqtt
{
    # Install required python libraries
    sudo pip3 install paho-mqtt

    #TODO: ask for mqtt ip and topic and subsitute those in script

}

function setup_api
{
    # Install required python libraries
    sudo pip3 install requests

    #TODO: ask for api host and api key and subsitute those in script
}

function install_service
{
    systemctl stop ads1115-current-sensor

    cp "$tmp_dir/ads1115-current-sensor.service" "/etc/systemd/system/ads-current-sensor.service"

    #TODO: ask if service should be automatically started at boot time
    systemctl enable ads1115-current-sensor
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

