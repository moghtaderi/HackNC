const int pwPin = 7;
long pulse, inches, cm;

void setup() 
{
  pinMode(pwPin, INPUT);
  Serial.begin(76800);
}

void loop()
{
  //if(Serial.available() > 0)
    //{
       //char letter = Serial.read();
       //if(letter == '1')
       //{
          
          pulse = pulseIn(pwPin, HIGH);
          inches = pulse/147;
          cm = inches * 2.54;

          delay(250);
          //Serial.println("\nThe sensor is on.");
          Serial.print(inches);
          //Serial.print("\n");
          //Serial.print(cm);
          //Serial.print("cm\n");
       //}
       //else if(letter == '0')
       //{
         // pulse = pulseIn(pwPin, LOW);
          //inches = pulse/147;
          //cm = inches * 2.54;

         // if(inches > 50)
          //{
           // inches = -1;
          //Serial.println("\nThe sensor is off.");
         // Serial.print(inches);
          
//       }
 //   }
    //}
}
