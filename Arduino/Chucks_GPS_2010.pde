//--------------------------------------------------------------
//  Program:      Burning Man 2010 Camp Finder
//  Description:  Runs on an Arduino using Adafruit GPS, Logger
//				  Compass and Liquidware touchscreen.
//  By:           Chuck Toussieng 
//--------------------------------------------------------------

#include <NewSoftSerial.h>
#include <math.h>
#include <avr/pgmspace.h>
#include <avr/sleep.h>
#include "AF_SDLog.h"
#include <Wire.h> 
#include <LibCompass.h>
#include "util.h"

// Power saving modes
#define SLEEPDELAY 0
#define TURNOFFGPS 0
#define LOG_RMC_FIXONLY 1
#define LED1PIN 6
#define LED2PIN 5
#define POWERPIN 4
#define BUFFSIZE 75

// Adafruit SD card logger
AF_SDLog card;
File f;

// Liquidware Touchscreen
int screen_TX_pin = 2;
int screen_RX_pin = 3;

NewSoftSerial touchSerial =  NewSoftSerial(screen_RX_pin, screen_TX_pin);


// GPS and location variables
char buffer[BUFFSIZE];
uint8_t bufferidx = 0;
uint8_t fix = 0; // current fix data
uint8_t i;
uint8_t hour, minute, second, year, month, date;
uint32_t latitude, longitude;
uint8_t groundspeed, trackangle;
char latdir, longdir, distLabel;
char status;
int velocity, angle, heading, turn;
long lat, lon, lattemp, lontemp;
float latdeg, londeg, x, y, km, time;
char *parseptr;
char buffidx;
uint32_t tmp;
float bearing = 0.0;
float threshold = 0.1;

LibCompass compass = LibCompass(0);

//--------------------------------------------------------------
// This is 2010 Camp at 6:30 and I according to the golden spike map.
//
const float destinationLat = 40.780492;
const float destinationLon = -119.220350;


//--------------------------------------------------------------
//
// GPS
//
// Example Results from the GPS module
//
// $PSRF103,<msg>,<mode>,<rate>,<cksumEnable>*CKSUM<CR><LF>
//
// <msg> 00=GGA,01=GLL,02=GSA,03=GSV,04=RMC,05=VTG
// <mode> 00=SetRate,01=Query
// <rate> Output every <rate>seconds, off=00,max=255
// <cksumEnable> 00=disable Checksum,01=Enable checksum for specified message
// Note: checksum is required
// Example 1: Query the GGA message with checksum enabled
// $PSRF103,00,01,00,01*25
//
// Example 2: Enable VTG message for a 1Hz constant output with checksum enabled
// $PSRF103,05,00,01,01*20
//
// Example 3: Disable VTG message
// $PSRF103,05,00,00,01*21
//
//--------------------------------------------------------------

#define SERIAL_SET   "$PSRF100,01,4800,08,01,00*0E\r\n"

// GGA-Global Positioning System Fixed Data, message 103,00
#define LOG_GGA 0
#define GGA_ON   "$PSRF103,00,00,01,01*25\r\n"
#define GGA_OFF  "$PSRF103,00,00,00,01*24\r\n"

// GLL-Geographic Position-Latitude/Longitude, message 103,01
#define LOG_GLL 0
#define GLL_ON   "$PSRF103,01,00,01,01*26\r\n"
#define GLL_OFF  "$PSRF103,01,00,00,01*27\r\n"

// GSA-GNSS DOP and Active Satellites, message 103,02
#define LOG_GSA 0
#define GSA_ON   "$PSRF103,02,00,01,01*27\r\n"
#define GSA_OFF  "$PSRF103,02,00,00,01*26\r\n"

// GSV-GNSS Satellites in View, message 103,03
#define LOG_GSV 0
#define GSV_ON   "$PSRF103,03,00,01,01*26\r\n"
#define GSV_OFF  "$PSRF103,03,00,00,01*27\r\n"

// RMC-Recommended Minimum Specific GNSS Data, message 103,04
#define LOG_RMC 1
#define RMC_ON   "$PSRF103,04,00,01,01*21\r\n"
#define RMC_OFF  "$PSRF103,04,00,00,01*20\r\n"

// VTG-Course Over Ground and Ground Speed, message 103,05
#define LOG_VTG 0
#define VTG_ON   "$PSRF103,05,00,01,01*20\r\n"
#define VTG_OFF  "$PSRF103,05,00,00,01*21\r\n"

// Switch Development Data Messages On/Off, message 105
#define LOG_DDM 0
#define DDM_ON   "$PSRF105,01*3E\r\n"
#define DDM_OFF  "$PSRF105,00*3F\r\n"

#define USE_WAAS 0     // useful in US, but slower fix
#define WAAS_ON    "$PSRF151,01*3F\r\n"       // the command for turning on WAAS
#define WAAS_OFF   "$PSRF151,00*3E\r\n"       // the command for turning off WAAS


//--------------------------------------------------------------
// Program Utilities

// read a Hex value and return the decimal equivalent
uint8_t parseHex(char c) {
  if (c < '0')
    return 0;
  if (c <= '9')
    return c - '0';
  if (c < 'A')
    return 0;
  if (c <= 'F')
    return (c - 'A')+10;
}

// read a String value and return the decimal equivalent
uint32_t parsedecimal(char *str) {
  uint32_t d = 0;
  
  while (str[0] != 0) {
   if ((str[0] > '9') || (str[0] < '0'))
     return d;
   d *= 10;
   d += str[0] - '0';
   str++;
  }
  return d;
}

// prints val with number of decimal places determine by precision
// NOTE: precision is 1 followed by the number of zeros for the desired number of decimial places
// example: printDouble( 3.1415, 100); // prints 3.14 (two decimal places)
void printDouble( double val, unsigned int precision) {

    touchSerial.print (int(val));  //prints the int part
    touchSerial.print("."); // print the decimal point
    unsigned int frac;
    
    if(val >= 0)
     frac = (val - int(val)) * precision;
    else
     frac = (int(val)- val ) * precision;
     
    touchSerial.print(frac,DEC) ;
}

// Blink out an error code
void error(uint8_t errno) {

  while(1) {
    for (i=0; i<errno; i++) {
      digitalWrite(LED1PIN, HIGH);
      digitalWrite(LED2PIN, HIGH);
      delay(100);
      digitalWrite(LED1PIN, LOW);
      digitalWrite(LED2PIN, LOW);
      delay(100);
    }
    for (; i<10; i++) {
      delay(200);
    }
  }

}

// Sleep to conserve power
void sleep_sec(uint8_t x) {
  while (x--) {
     // set the WDT to wake us up!
    WDTCSR |= (1 << WDCE) | (1 << WDE); // enable watchdog & enable changing it
    WDTCSR = (1<< WDE) | (1 <<WDP2) | (1 << WDP1);
    WDTCSR |= (1<< WDIE);
    set_sleep_mode(SLEEP_MODE_PWR_DOWN);
    sleep_enable();
    sleep_mode();
    sleep_disable();
  }
}

SIGNAL(WDT_vect) {
  WDTCSR |= (1 << WDCE) | (1 << WDE);
  WDTCSR = 0;
}

// Grab the time from the GPRMC Sentence
void grabTheTime(char *p) {
   
  tmp = parsedecimal(p);
  
  //some code to convert to Pacific Time
  if(tmp >= 70000){
     hour = (tmp / 10000) - 7;
  } else {
      hour = 17 + (tmp /10000); 
  }
  //end Pacific Time conversion
    
  //hour = (tmp / 10000); is regular UTC
  
  minute = (tmp / 100) % 100;
  second = tmp % 100;
  
 
  touchSerial.print("$T");
  
  if(hour < 10)
    touchSerial.print('0');
  
  touchSerial.print(hour,DEC);
  touchSerial.print(":");

  if(minute < 10)
    touchSerial.print('0');

  touchSerial.print(minute,DEC);
  touchSerial.print(":");

  if(second < 10)
    touchSerial.print('0');

  touchSerial.print(second,DEC);
  touchSerial.print('\n');

}

//------------------------------------------
void showFix() 
{
    if(fix == 0) {
      touchSerial.print("$Sno fix  :(");
      touchSerial.print('\n');  
    }
}


//--------------------------------------------------------------
// Location Utilities

// Function to calculate the distance between two waypoints
float calc_dist(float flat1, float flon1, float flat2, float flon2) {

	float dist_calc = 0.0;
	float dist_calc2 = 0.0;
	float diflat = 0.0;
	float diflon = 0.0;

	// I've to spplit all the calculation in several steps. 
	// If i try to do it in a single line the arduino will explode.
	diflat = radians(flat2 - flat1);
	flat1 = radians(flat1);
	flat2 = radians(flat2);
	diflon = radians((flon2) - (flon1));

	dist_calc = (sin(diflat/2.0) * sin(diflat/2.0));
	dist_calc2 = cos(flat1);
	dist_calc2* = cos(flat2);
	dist_calc2* = sin(diflon/2.0);
	dist_calc2* = sin(diflon/2.0);
	dist_calc += dist_calc2;

	dist_calc = (2*atan2(sqrt(dist_calc), sqrt(1.0-dist_calc)));

	dist_calc*= 6371000.0; //Converting to meters

	// Bearing to destination
	flon1 = radians(flon1);  // also must be done in radians
	flon2 = radians(flon2);  // radians. duh.
	
	bearing = atan2(sin(flon2-flon1)*cos(flat2),cos(flat1)*sin(flat2)-sin(flat1)*cos(flat2)*cos(flon2-flon1)),2*3.1415926535;
	bearing = bearing*180/3.1415926535;  // convert from radians to degrees
	int brg = bearing; // make it a integer now

	if(brg < 0) {
  		bearing += 360;   // If the bearing is negative then add 360 to make it positive
	}

	// Heading to destination
	heading = (int)compass.GetHeading();

	// NOTE!!!!!!!!!
	// This project has the compass inverted, so correct here quickly
	if(heading >= 0 && heading < 180)
  		heading = heading + 180;
	else
  		heading = heading - 180;

	//Setup turn flag
	int x4 = heading - bearing;   //getting the difference of our current heading to our needed bearing

	//Which way do we need to turn?
	if(x4 >= -180) 
  		if(x4 <= 0) 
    		turn = 8;   //set turn =8 which means "right"         

	if(x4 <- 180)
  		turn = 5;      //set turn = 5 which means "left"


	if(x4 >= 0)
  		if(x4 < 180)
    		turn = 5;   //set turn = 5 which means "left"

	if(x4 >= 180)     //set turn =8 which means "right"
  		turn = 8;

	if(x4 == 0)
    	turn = 3;   //then set turn = 3 meaning go "straight"

	
	return dist_calc;

}



//--------------------------------------------------------------
// Setup!
//
void setup() {
  WDTCSR |= (1 << WDCE) | (1 << WDE);
  WDTCSR = 0;
  
  touchSerial.begin(9600);
  
  Serial.begin(4800);
  putstring_nl("GPSlogger");
  putstring_nl("Initializing SD Card");
  
  pinMode(LED1PIN, OUTPUT);
  pinMode(LED2PIN, OUTPUT);
  pinMode(POWERPIN, OUTPUT);
  digitalWrite(POWERPIN, LOW);

  if (!card.init_card()) {
    putstring_nl("Card init. failed!");
    error(1);
  }
  if (!card.open_partition()) {
    putstring_nl("No partition!");
    error(2);
  }
  if (!card.open_filesys()) {
    putstring_nl("Can't open filesys");
    error(3);
  }
  if (!card.open_dir("/")) {
    putstring_nl("Can't open /");
    error(4);
  }

  strcpy(buffer, "GPSLOG00.TXT");
  for (buffer[6] = '0'; buffer[6] <= '9'; buffer[6]++) {
    for (buffer[7] = '0'; buffer[7] <= '9'; buffer[7]++) {
      //putstring("\ntrying to open ");Serial.println(buffer);
      f = card.open_file(buffer);
      if (!f)
        break;
      card.close_file(f);
    }
    if (!f)
      break;
  }

  if(!card.create_file(buffer)) {
    putstring("couldnt create ");
    Serial.println(buffer);
    error(5);
  }
  f = card.open_file(buffer);
  if (!f) {
    putstring("error opening ");
    Serial.println(buffer);
    card.close_file(f);
    error(6);
  }
  putstring("writing to ");
  Serial.println(buffer);
  putstring_nl("ready!");
  
  putstring(SERIAL_SET);
  delay(250);

  if (LOG_DDM)
    putstring(DDM_ON);
  else
    putstring(DDM_OFF);
  delay(250);

  if (LOG_GGA)
    putstring(GGA_ON);
  else
    putstring(GGA_OFF);
  delay(250);

  if (LOG_GLL)
    putstring(GLL_ON);
  else
    putstring(GLL_OFF);
  delay(250);

  if (LOG_GSA)
    putstring(GSA_ON);
  else
    putstring(GSA_OFF);
  delay(250);

  if (LOG_GSV)
    putstring(GSV_ON);
  else
    putstring(GSV_OFF);
  delay(250);

  if (LOG_RMC)
    putstring(RMC_ON);
  else
    putstring(RMC_OFF);
  delay(250);

  if (LOG_VTG)
    putstring(VTG_ON);
  else
    putstring(VTG_OFF);
  delay(250);

  if (USE_WAAS)
    putstring(WAAS_ON);
  else
    putstring(WAAS_OFF);

}

//--------------------------------------------------------------
// And the Loop!
//
void loop() {

  char c;
  uint8_t sum;
 
  // read one 'line' from the GPS on the Serial
  if (Serial.available()) {
    
    c = Serial.read();
    
    if (bufferidx == 0) {
      while (c != '$')
        c = Serial.read(); // wait until we get a $
    }
    
    buffer[bufferidx] = c;

    if (c == '\n') {
      putstring_nl("EOL");
      Serial.print(buffer);
      buffer[bufferidx+1] = 0; // terminate it

        if (buffer[bufferidx-4] != '*') {
          // no checksum?
          Serial.print('*', BYTE);
          bufferidx = 0;
          return;
        }
        
        // get checksum
        sum = parseHex(buffer[bufferidx-3]) * 16;
        sum += parseHex(buffer[bufferidx-2]);

        // check checksum
        for (i=1; i < (bufferidx-4); i++) {
          sum ^= buffer[i];
        }

        if (sum != 0) {
          //putstring_nl("Cxsum mismatch");
          Serial.print('~', BYTE);
          bufferidx = 0;
          return;
        }

        // got good data!      
        if (strstr(buffer, "GPRMC")) {
          // find out if we got a fix
          char *p = buffer;
          p = strchr(p, ',')+1;       //This will be pointing at the time
          
          grabTheTime(p);
        
          p = strchr(p, ',')+1;       // skip to 3rd item, the Fix status

          if (p[0] == 'V') {
            showFix();
            digitalWrite(LED1PIN, LOW);
            fix = 0;
          } else {
            showFix();
            digitalWrite(LED1PIN, HIGH);
            fix = 1;
          }
          
           p = strchr(p, ',')+1;       // skip to 4th item, the Latitude
           
           // grab latitude & long data
           // latitude
           latitude = parsedecimal(p);
           if (latitude != 0) {
              latitude *= 10000;
              p = strchr(p, '.')+1;
              latitude += parsedecimal(p);
      
              // This next conversion is only to display the long variable on the Sparkfun LCD screen.  
			  // I couldn't display the floats
              lat = (long)latitude;
      
              // The next two lines are used to convert the latitude data in GPS output into Degrees.  
			  // The math for this came from http://www.csgnetwork.com/gpsdistcalc.html    
              lattemp = (lat / 1000000) * 1000000;
              latdeg = (lattemp / 1000000.0) + ((lat - lattemp) / 600000.0); 
      
              if (latdir == 'S'){
                latdeg = -latdeg;
              }
            }
    
          p = strchr(p, ',') + 1;
          // Read latitude N/S data
          if (p[0] != ',') {
            latdir = p[0];
          }
    
          // longitude
          p = strchr(p, ',') + 1;
          longitude = parsedecimal(p);
          if (longitude != 0) {
            longitude *= 10000;
            p = strchr(p, '.')+1;
            longitude += parsedecimal(p);
            // Again converting to a long in order to display on the Sparkfun Serial LCD
            lon = (long) longitude;
            // Again converting from GPS coordinates into Degrees Decimal
            lontemp = (lon / 1000000) * 1000000;
            londeg = (lontemp / 1000000.0) + ((lon - lontemp) / 600000.0); 
            if (longdir == 'W'){
              londeg = -londeg;
            }
          }
          p = strchr(p, ',')+1;
          // read longitude E/W data
          if (parseptr[0] != ',') {
            longdir = p[0];
          }
          
          // groundspeed
          p = strchr(p, ',')+1;
          groundspeed = parsedecimal(p);
          velocity = (int) groundspeed;
          
          // track angle
          p = strchr(p, ',')+1;
          trackangle = parsedecimal(p);
          angle = (int) trackangle;
           
           
         if(fix) {
           
           // distance     
           float ans = calc_dist(latdeg,londeg,destinationLat,destinationLon);
          
           //ttg
           time = ((ans / 1000) / 1.8) / velocity;
          
           if(ans >= 1000) {
             ans = (ans / 1000);
             distLabel = 'k';
           } else {
             distLabel = 'm';
           }  
           
           delay(100);
           
           //Write Heading Info sentence to Touch Shield: $H,bearing,heading,distance,distance label,turn,knots,mph,time to go
           touchSerial.print("$H,");
           touchSerial.print((int)bearing,DEC);
           touchSerial.print(",");
           touchSerial.print((int)heading,DEC);
           touchSerial.print(",");
           printDouble(ans,100);
           touchSerial.print(",");
           touchSerial.print(distLabel);
           if(turn == 5)
             touchSerial.print(",L,");
           else if(turn == 8)
             touchSerial.print(",R,");
           else if(turn == 3)
             touchSerial.print(",S,");
           else
             touchSerial.print(",U,"); //Unknown
           touchSerial.print(velocity,DEC);
           touchSerial.print(",");
           touchSerial.print(int(velocity*1.15077945),DEC);
           touchSerial.print(",");  
           printDouble(time,100);
           touchSerial.print(",");
           printDouble(ans,100);
           touchSerial.print(distLabel);
           touchSerial.print('\n');  
         }      
          
        } // If is a GPRMC Sentence
      
        if (LOG_RMC_FIXONLY) {
          if (!fix) {
            Serial.print('_', BYTE);
            bufferidx = 0;
            return;
          }
        }
      
        // Awesome! lets log it!
        Serial.print(buffer);
        Serial.print('#', BYTE);
        digitalWrite(LED2PIN, HIGH);      // sets the digital pin as output

        if(card.write_file(f, (uint8_t *) buffer, bufferidx) != bufferidx) {
          putstring_nl("can't write!");
          return;
        }

        digitalWrite(LED2PIN, LOW);
      
        bufferidx = 0;

        // Turn off GPS module?
        if (TURNOFFGPS) {
          digitalWrite(POWERPIN, HIGH);
        }

        sleep_sec(SLEEPDELAY);
        digitalWrite(POWERPIN, LOW);
        return;
      
    }  // End if is a newline
    
    bufferidx++;
    if (bufferidx == BUFFSIZE-1) {
       Serial.print('!', BYTE);
       bufferidx = 0;
    }
    
  } //End if Serial available

}


//------------------------------------------
// End code
//------------------------------------------