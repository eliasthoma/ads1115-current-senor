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
import logging
import math
import threading
import time

# Imports for ADS1115
import board
import busio
import adafruit_ads1x15.ads1115 as ADS
from adafruit_ads1x15.ads1x15 import Mode
from adafruit_ads1x15.analog_in import AnalogIn

# Imports for MQTT
from paho.mqtt import client as mqtt_client

# Import for API calling
import requests

##################### Settings #####################
emoncms = False
emoncms_host = 'localhost'
mqtt = True
mqtt_host = 'localhost'
mqtt_port = 1883
mqtt_client_id = f'python-mqtt-current-sensor'
mqtt_username = 'emonpi'
mqtt_password = 'emonpimqtt2016'
mqtt_basetopic = 'emon/python-mqtt-current-sensor/'
####################################################

def connect_mqtt():
    def on_connect(client, userdata, flags, rc):
        if rc == 0:
             logging.info('Connected to MQTT Broker!')
        else:
             logging.info('Failed to connect, return code %d\n', rc)

    client = mqtt_client.Client(mqtt_client_id)
    client.username_pw_set(mqtt_username, mqtt_password)
    client.on_connect = on_connect
    client.connect(mqtt_host, mqtt_port)
    return client

def calcIrms(number_of_samples, client):
    sumI1 = 0
    sumI2 = 0
    sumI3 = 0
    offsetI1 = 0
    offsetI2 = 0
    offsetI3 = 0

    for x in range(number_of_samples):
        # Phase 1
        sample1 = chan0104.value
        offsetI1 = ( offsetI1 + (sample1-offsetI1)/1024)
        filteredI1 = sample1 - offsetI1

        sqI1 = filteredI1 * filteredI1
        sumI1 += sqI1

        # Phase 2
        sample2 = chan0204.value
        offsetI2 = ( offsetI2 + (sample2-offsetI2)/1024)
        filteredI2 = sample2 - offsetI2

        sqI2 = filteredI2 * filteredI2
        sumI2 += sqI2

        # Phase 3
        sample3 = chan0304.value
        offsetI3 = ( offsetI3 + (sample3-offsetI3)/1024)
        filteredI3 = sample3 - offsetI3

        sqI3 = filteredI3 * filteredI3
        sumI3 += sqI3
    
    I_RATIO = 150 * (3260/1000.0) / (1<<16)
    I1rms = I_RATIO * math.sqrt(sumI1 / number_of_samples)
    I2rms = I_RATIO * math.sqrt(sumI2 / number_of_samples)
    I3rms = I_RATIO * math.sqrt(sumI3 / number_of_samples)

    logging.info('Calculation finished! Current:  %03.2f A  | %03.2f A  |  %03.2f A',  I1rms, I2rms, I3rms)
  
    if emoncms:
        logging.info('Uploading via API-Call to EmonCMS.')
        requests.get('http://localhost/input/post?node=python-mqtt-current-sensor&fulljson={"current1":{},"current2":{},"current3":{}}'.format(I1rms, I2rms, I3rms)) 
    
    if mqtt:
        logging.info('Uploading to MQTT-Queue %s/current<1/2/3>', mqtt_basetopic)
  
        client.publish( mqtt_basetopic + 'current1', I1rms)
        client.publish( mqtt_basetopic + 'current2', I2rms)
        client.publish( mqtt_basetopic + 'current3', I3rms)
        client.publish( mqtt_basetopic + 'current', I1rms + I2rms + I3rms)

# Main programm
if __name__ == '__main__':
    format = '%(asctime)s: %(message)s'
    logging.basicConfig(format=format, level=logging.INFO, datefmt='%H:%M:%S')

    # Initalisation of I2C and ADS1115
    i2c = busio.I2C(board.SCL, board.SDA, frequency=4000000)
    ads = ADS.ADS1115(i2c)
    ads.gain = 1
    ads.data_rate = 860
    ads.mode = Mode.CONTINUOUS

    # Initalisation of ADS-Channels
    chan0104 = AnalogIn(ads, ADS.P0, ADS.P3)
    chan0204 = AnalogIn(ads, ADS.P1, ADS.P3)
    chan0304 = AnalogIn(ads, ADS.P2, ADS.P3)

    if mqtt:
        client = connect_mqtt()
        client.loop_start()

    # Main loop
    while(True):
        calcIrms(2048, client)
