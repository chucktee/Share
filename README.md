# Share
Shared Code

##Chucks_GPS_2010.pde
This was built in 3 days before BurningMan 2010.  It's the code for my GPS camp finder with touchscreen interface and GPS logging.  
This is a working example of how I write code that I will probably be the only one viewing it.  Just enough to hopefully come back and figure out what I was doing.

##I2C_Slave.ino
This is a WIP of a remote sensor platform running on an Arduino.  This is currently meant to monitor the battery health and use a Sainsmart relay to shutoff the battery if the charge falls below a critical rate.  This helps save expensive SLA batteries that I have in various remote / solar powered projects such as my APRS iGATE.

This is written in a style where I would forsee sharing it with others to extend.

- Monitors battery voltage through a voltage divider
- Monitors temperature and humidity with a [DHT22 Sensor](http://www.adafruit.com/products/385?gclid=CL-95abFpMQCFQenaQodpaQAVA)
- Controls the battery connection with a [Sainsmart relay](http://www.sainsmart.com/arduino-compatibles-1/relay.html)





