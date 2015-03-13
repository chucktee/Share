//--------------------------------------------------------------
//  Program:      I2C Sensor Slave - I2C_Slave.c
//  Description:  Runs on an Arduino which performs several tasks
//                via commands sent over I2C from a Raspberry Pi
//  By:           Chuck Toussieng help from  
//--------------------------------------------------------------

#include <Wire.h>                 // I2C library
#include <DHT.h>                  // DHT Temp sensor library

// Basics
#define LED_PIN 13                // Which pin to use for toggling the LED

// Basics Variables
int command = 0;                  // Command received over the I2C buss
int ledstate = 0;                 // Onboard LED state
float response = 0.0;             // Holder for result to return over the I2C bus
double internal_temp = 0.0;       // Arduino internal temperature


// I2C Commmands
#define LED 1                     // For testing; toggles Arduino onboard LED on and off
#define INTTEMP 2                 // Return the internal processor temp 
#define EXTTEMP 3                 // Return the external temp from DHTxx
#define HUMID 4                   // Return the humidity from DHTxx
#define BATTVOLT 5                // Return the voltage of a battery connected to a voltage divider 
#define POWEROFF 6                // Turn off a power relay
#define POWERON 7                 // Turn on a power relay
#define SLAVE_ADDRESS 0x04        // This Arduino's I2C Address


// DHT 
#define DHTPIN 2                  // What digital pin we're connected to
#define DHTTYPE DHT22             // DHT 22  (AM2302)
DHT dht(DHTPIN, DHTTYPE);         // Initialize DHT sensor for normal 16mhz Arduino
  
// DHT Variables
float current_humidity = 0.0;
float current_temperatureC = 0.0;
float current_temperatureF = 0.0;


// Battery Monitoring
// How to calculate these constants:  Calculate and build your voltage divider based on needs.
// 1. Measure the voltage across both resistors together- 
// 2. Measure the voltage across the R2 resistor (100K in our case)
// 3. Take First measure / Second measure to find CALIBRATED_DIVIDER. I used a 330K as R1 and 100K as R2  This will allow 20V MAX
// NOTE: I like to double check values with an online voltage divider calculator :)  No one likes to let out the magic blue smoke
// 4. If you want good accuracy, we also need to know this specific Arduino's voltage seen on the 5V pin.  
//    This will vary by whereever you are supplying power to the board.  Plugged into the USB, I see 5.03V.  If I'm powering through Vin, I see 4.01V.
//    Know your regulator and the path power takes.  Plug that into THIS_ARDUINOS_VOLTAGE

#define READ_BATTERY_PIN A2
#define NUM_SAMPLES 10
const float CALIBRATED_DIVIDER = 4.285;
const float THIS_ARDUINOS_VOLTAGE = 5.03;

// Battery Monitoring Variables
int samples = 0;          // Current sample voltage
int sum_of_readings = 0;  // Sum of voltage samples taken
float voltage = 0.0;      // Calculated voltage
 


//--------------------------------------------------
//
// Program Setup
//
void setup() {
  
  // Just for testing the I2C bus
  pinMode(LED_PIN, OUTPUT);
   
  // initialize I2C as slave
  Wire.begin(SLAVE_ADDRESS);
 
  // define callbacks for i2c communication
  Wire.onReceive(receiveData);
  Wire.onRequest(sendData);

}

//--------------------------------------------------
//
// Main Loop 
//
void loop() {
 
  // Refresh all sensors and keep the data on hand.
  voltage = getBatteryVoltage();
  
  internal_temp = getInternalTemp();
 
  // DHT
  // Wait 2 seconds between measurements.
  // This is a limitation of the sensor
  delay(2000);
  current_humidity = dht.readHumidity();
  current_temperatureC = dht.readTemperature();
  current_temperatureF = dht.readTemperature(true);

}



//--------------------------------------------------
//
// I2C functions

//--------------------------------------------------
// I2C - received data
void receiveData(int byteCount) {
 
 while(Wire.available()) {
   
  command = Wire.read();
 
  if (command == LED) {
   if (ledstate == 0) {
    digitalWrite(LED_PIN, HIGH); // set the LED on
    ledstate = 1;
   } else {
    digitalWrite(LED_PIN, LOW); // set the LED off
    ledstate = 0;
   }
   response = ledstate;
  }
 
  if(command == INTTEMP) {
   response = internal_temp;
  }
  
  if(command == EXTTEMP) {
   response = current_temperatureC;
  }
  
  if(command == HUMID) {
   response = current_humidity;
  }
  
  if(command == BATTVOLT) {
   response = voltage;
  }
  
  if(command == POWERON) {
    //Switch on the relay WIP
   response = 1;
  }
  
  if(command == POWEROFF) {
    //Switch off the relay WIP
   response = 1;
  }
  
 }
 
}
 
 
//-------------------------------------------------- 
// I2C - send data
void sendData() {
  
  // How to handle sending the result across our limited pipe?
  // Convert the float values in a vector of 4 bytes
  char vector[4];
  memcpy(vector, (char*)&(response), 4);
  
  Wire.write(vector, 4);
  
}


//--------------------------------------------------
// Get the internal temperature of the Arduino
// This is from the Arduino playground
// These values for ATmega328 - refer to the Google for different chips
double getInternalTemp(void) {
  
 unsigned int wADC;
 double t;
 
 ADMUX = (_BV(REFS1) | _BV(REFS0) | _BV(MUX3));
 ADCSRA |= _BV(ADEN);   // enable the ADC
 delay(20);             // wait for voltages to become stable.
 ADCSRA |= _BV(ADSC);   // Start the ADC
 while (bit_is_set(ADCSRA,ADSC));
 wADC = ADCW;
 t = (wADC - 324.31 ) / 1.22;
 
 return (t);

}


//--------------------------------------------------
//
// Calculate the source battery voltage
//
float getBatteryVoltage(void) {
  
  // Belt+Suspenders reset  
  samples = 0;
  sum_of_readings = 0;
    
  // Take a number of analog pin samples which we will smooth with an average
   while (samples < NUM_SAMPLES) {
        sum_of_readings += analogRead(READ_BATTERY_PIN);
        samples++;
        delay(100);
    }
    
    // Calculate the voltage. 0-1023 is the maximum for the 10bit ADC in this particular Arduino flavor
    voltage = ((float)sum_of_readings / (float)NUM_SAMPLES * THIS_ARDUINOS_VOLTAGE) / 1024.0;
  
    // Now adjust to pre-Voltage Divider value 
    voltage = voltage * CALIBRATED_DIVIDER;
 
    return(voltage);

}
