#include <TinyGPS.h>

// GPS part

/*
 Sensor  Elegoo MEGA
  VCC -> 5V
  GND -> GND
  TX -> 19
  RX -> 18
*/

#include <TinyGPSPlus.h>

void getLatAndLon(double* Latitude, double* Longitude, TinyGPSPlus* obj){

  while(1){
    if(!Serial1.available()) {
      return;
    }
    obj->encode(Serial1.read());
    if(obj->location.isUpdated()){
      *Latitude = obj->location.lat();
      *Longitude = obj->location.lng();
      printLatAndLon(*Latitude, *Longitude);
      return;
    }
  }

}

void printLatAndLon(double Latitude, double Longitude){
  Serial.print("g");
  Serial.print(Latitude, 6);
  Serial.print(",");
  Serial.println(Longitude, 6 );
}

void printLatAndLonFloatExp(float Latitude, float Longitude){
  Serial.print("Latitude: ");
  Serial.print(Latitude, 6);
  Serial.print(", ");
  Serial.print("Longitude: ");
  Serial.println(Longitude, 6);
}

// MPU part

/*
 Sensor  Elegoo MEGA
  VCC -> 3.3V
  GND -> GND
  SCL -> 21
  SDA -> 20
*/

#include<Wire.h>

const int MPU = 0x68; // I2C address of the MPU-6050

// This should be executed once at startup
void wireStartMPU(){
  Wire.begin();
  Wire.beginTransmission(MPU);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0);     // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);
}

// This should be executed once every time 
// before reading from the MPU sensor
void prepareToReadMPU(){
  Wire.beginTransmission(MPU);
  Wire.write(0x3B);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU, 14, true); // request a total of 14 registers
}

void readAccelerometer(int16_t* x, int16_t* y, int16_t* z){
  prepareToReadMPU();

  *x = Wire.read() << 8 | Wire.read(); // 0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)
  *y = Wire.read() << 8 | Wire.read(); // 0x3D (ACCEL_YOUT_H) & 0x3E (ACCEL_YOUT_L)
  *z = Wire.read() << 8 | Wire.read(); // 0x3F (ACCEL_ZOUT_H) & 0x40 (ACCEL_ZOUT_L)
}

void readGyroscope(int16_t* x, int16_t* y, int16_t* z){
  prepareToReadMPU();

  *x = Wire.read() << 8 | Wire.read(); // 0x43 (GYRO_XOUT_H) & 0x44 (GYRO_XOUT_L)
  *y = Wire.read() << 8 | Wire.read(); // 0x45 (GYRO_YOUT_H) & 0x46 (GYRO_YOUT_L)
  *z = Wire.read() << 8 | Wire.read(); // 0x47 (GYRO_ZOUT_H) & 0x48 (GYRO_ZOUT_L)
}

void readMPU(int16_t* ax, int16_t* ay, int16_t* az, int16_t* gx, int16_t* gy, int16_t* gz){

  readAccelerometer(ax, ay, az);
  readGyroscope(gx, gy, gz);

}

void writeAccelerometer(int16_t x, int16_t y, int16_t z){
  Serial.print("A");
  Serial.print(x);
  Serial.print(",");
  Serial.print(y);
  Serial.print(",");
  Serial.println(z);
}

void writeGyroscope(int16_t x, int16_t y, int16_t z){
  Serial.print("G");
  Serial.print(x);
  Serial.print(",");
  Serial.print(y);
  Serial.print(",");
  Serial.println(z);
}

/*
  ERRORS list:
    - E1: GPS not connected
*/

TinyGPSPlus gps;
double lat, lon;

int16_t pAcX, pAcY, pAcZ, pGyX, pGyY, pGyZ;
int16_t AcX, AcY, AcZ, GyX, GyY, GyZ;

void setup(){

  Serial.begin(9600);
  Serial1.begin(9600);

  wireStartMPU();

  readAccelerometer(&pAcX, &pAcY, &pAcZ);
  readGyroscope(&pGyX, &pGyY, &pGyZ);

}

void loop(){
  
  // Keep track of gps data
  gps.encode(Serial1.read());

  // If it's required to get the gps position
  if(Serial.read() == 'g'){
    getLatAndLon(&lat, &lon, &gps);
  }

  readAccelerometer(&AcX, &AcY, &AcZ);
  // readGyroscope(&GyX, &GyY, &GyZ);

  if(abs(AcZ - pAcZ) >= 2000){
      writeAccelerometer(AcX, AcY, AcZ);
      getLatAndLon(&lat, &lon, &gps);
      printLatAndLon(lat, lon);
  }

  pAcX = AcX;
  pAcY = AcY;
  pAcZ = AcZ;

  /*
    pGyX = GyX;
    pGyY = GyY;
    pGyZ = GyZ;
  */

}