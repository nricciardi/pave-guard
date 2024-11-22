// GPS part

/*
 Sensor  Elegoo MEGA
  VCC -> 5V
  GND -> GND
  TX -> 19
  RX -> 18
*/

#include <TinyGPSPlus.h>

// Reads from Serial1 and retrieves Latitude and Longitude
void getLatAndLon(double* Latitude, double* Longitude, TinyGPSPlus* obj){

  while (1) {
    // If Serial1 is not connected, returns
    if(!Serial1.available()) break;
    // Reads and parse a char from Serial1
    obj->encode(Serial1.read());
    // If enough chars have been parsed, returns the location
    if(obj->location.isUpdated()){
      *Latitude = obj->location.lat();
      *Longitude = obj->location.lng();
      break;
    }
  }

}

// Writes to Serial the values of latitude and longitude
// FORMAT: gR[lat],[lon]\n - for routine send
// FORMAT: gE[lat],[lon]\n - for exceptional send
void printLatAndLon(double Latitude, double Longitude){
  Serial.print("g"); Serial.print(Latitude, 8); 
  Serial.print(","); Serial.println(Longitude, 8);
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
  Wire.begin(); Wire.beginTransmission(MPU);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0);     // Wakes up the MPU-6050
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

// Reads and overwrites values of x,y,z accelerations
void readAccelerometer(int16_t* x, int16_t* y, int16_t* z){
  prepareToReadMPU();

  *x = Wire.read() << 8 | Wire.read(); // 0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)
  *y = Wire.read() << 8 | Wire.read(); // 0x3D (ACCEL_YOUT_H) & 0x3E (ACCEL_YOUT_L)
  *z = Wire.read() << 8 | Wire.read(); // 0x3F (ACCEL_ZOUT_H) & 0x40 (ACCEL_ZOUT_L)
}

// Reads and overwrites values of x,y,z gyroscope
void readGyroscope(int16_t* x, int16_t* y, int16_t* z){
  prepareToReadMPU();

  *x = Wire.read() << 8 | Wire.read(); // 0x43 (GYRO_XOUT_H) & 0x44 (GYRO_XOUT_L)
  *y = Wire.read() << 8 | Wire.read(); // 0x45 (GYRO_YOUT_H) & 0x46 (GYRO_YOUT_L)
  *z = Wire.read() << 8 | Wire.read(); // 0x47 (GYRO_ZOUT_H) & 0x48 (GYRO_ZOUT_L)
}

// Writes to output the values of the accelerations
// FORMAT: A[x],[y],[z]\n
void writeAccelerometer(int16_t x, int16_t y, int16_t z){
  Serial.print("A"); Serial.print(x);
  Serial.print(","); Serial.print(y);
  Serial.print(","); Serial.println(z);
}

// Writes to output the values of the gyroscope
// FORMAT: G[x],[y],[z]\n
void writeGyroscope(int16_t x, int16_t y, int16_t z){
  Serial.print("G"); Serial.print(x);
  Serial.print(","); Serial.print(y);
  Serial.print(","); Serial.println(z);
}

const int buf_size = 110;
const unsigned long interval = 20;

TinyGPSPlus gps;
double lat, lon;
double* pLat,* pLon;

int16_t mAcX, mAcY, mAcZ;
int16_t* pAcX,* pAcY,* pAcZ;
char i;

unsigned long previousTime;

int16_t getMedian(int16_t* list, int len){

  return list[len / 2];

}

void insertSorted(int16_t* list, int len, int16_t to_insert){

  if(len == 0){
    list[0] = to_insert; return;
  }

  int j = len - 1;
  while (j >= 0) {
    if(list[j] > to_insert){ list[j + 1] = list[j]; }
    else{ break; }
    j--;
  }

  list[j + 1] = to_insert;

}

void setup(){

  Serial.begin(9600);
  Serial1.begin(9600);

  pAcX = calloc(sizeof(int16_t), buf_size);
  pAcY = calloc(sizeof(int16_t), buf_size);
  pAcZ = calloc(sizeof(int16_t), buf_size);

  pLat = calloc(sizeof(double), buf_size);
  pLon = calloc(sizeof(double), buf_size);
  i = 0;

  previousTime = millis();

  wireStartMPU();

  readAccelerometer(&pAcX[i], &pAcY[i], &pAcZ[i]);
  // readGyroscope;
  getLatAndLon(&pLat[i], &pLon[i], &gps);
  i++;

}

void empty_buffer() {

  mAcX = getMedian(pAcX, i); mAcY = getMedian(pAcY, i); mAcZ = getMedian(pAcZ, i);
    for(int j = 0; j < i; j++){
      writeAccelerometer(pAcX[j] - mAcX, pAcY[j] - mAcY, pAcZ[j] - mAcZ);
      printLatAndLon(pLat[j], pLon[j]);
    } i = 0;
  Serial.print("\n\n");

}

void loop(){

  if(millis() - previousTime < interval) return;
  else previousTime = millis();

  if(i >= buf_size){
    empty_buffer();   
  } else {
    readAccelerometer(&mAcX, &mAcY, &mAcZ);
    insertSorted(pAcX, i, mAcX); insertSorted(pAcY, i, mAcY); insertSorted(pAcZ, i, mAcZ);
    getLatAndLon(&pLat[i], &pLon[i], &gps); i++;
    if(mAcX >= 13000 || mAcY >= 13000){ empty_buffer(); return; }
  }

}