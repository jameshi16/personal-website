---
layout: post
title: MakeBlock DC Encoder Motors - The Encoding Part
date: 2019-03-25 09:30
published: true
---

Good morning! :coffee:.

In the course I've enrolled in for the vacation, I had to work with the [MakeBlock 25mm DC Encoder Motor](http://www.robotpark.com/DC-Encoder-Motor-Pack-25mm-Makeblock-En), which looks something like this:

<img src="/images/20190325_1.jpg" width="200px" alt="The 25mm DC Encoder Motor"/>

It's a really nice **DC** motor. It spins. It stops. It starts. Good torque. Pretty okay motor, except for its price; although I can't complain because I got it for free.

**However**: I'll complain about one thing; the lack of documentation. I had to perform a few rounds of trial and error just to make sense of the value I'm reading from the "encoding" part of the motor. For context, this motor has a few pins: M+, M-, GND, VCC, A, and B. After a round of searching, I found [this link](http://learn.makeblock.com/ultimate2-arduino-programming/), which displayed the following code:
```cpp
#include "MeMegaPi.h"
const byte interruptPin =18;    
const byte NE1=31;                 
long count=0;
unsigned long time;
unsigned long last_time;
MeMegaPiDCMotor motor1(PORT1B);   
uint8_t motorSpeed = 100;
void setup()
{
    pinMode(interruptPin, INPUT_PULLUP);
    pinMode(NE1, INPUT);
    attachInterrupt(digitalPinToInterrupt(interruptPin), blink,RISING);   
    Serial.begin(9600);   
}
void loop()
{
    motor1.run(motorSpeed);       // value: between -255 and 255
    time =millis(); 
    if(time-last_time>2000)    
    {
          Serial.println(count);
          last_time=time;
   }
}
void blink()
{
    if (digitalRead(NE1)>0)   
    count++;
    else
    count--;
}
```

---

# What the code does
It reads an analog value via interrupt from pin A (the interrupt pin) and pin B (the NE1 pin). This produces the following output after 10 revolutions:
```
0
-1436
-3177
-4917
-5741
```

And so, my first question was: "なに これ"? (what's this) 
Here is what I know:

1. This is some kind of encoder, and I've generalized it to be either a rotary encoder, or a hall effect encoder (both are revolution counting encoders)
2. The values make no sense

---

# What I did
I went online to search for solutions, to no avail. This product has a niche market, because it was designed for use with a MakeBlock microcontroller, like the [MegaPi](http://learn.makeblock.com/en/megapi/), hence, it was difficult to find any kind of answers to this question I had.

After a while, I decided to do a little bit of a trial and error. By recognizing some patterns in subsequent outputs, I realized the following:

1. The weird numbers are related to the Gear Ratio of the motor.
2. The weird numbers are related to another constant.

With that, I performed a few calculations, to find that the number was between 7.5 to 8.5. Testing with 7 and 8, I figured out that 8 was the correct answer. In other words, the formula for calculating the **number of revolutions** from the **werid number thing** produced by the encoder motor is: `(weird number thing / gear ratio) / 8`. After discussing with my friend a little, I realized that the '8' can represent the number of ticks within the motor; in his words: "(there) could be the 8 points about that revolution". Afterwards, I found this [fourm post](https://forum.makeblock.com/t/information-about-25mm-dc-encoder-motor/10791/3), which had the Original Poster (OP) sharing the same frustration (lack of documentation) as me, but more importantly, contained the information that the "ticks per rev is 8". Alongside the Gear Ratio, this makes the formula the correct method of calculating the revolutions per minute.

Here's the working Arduino sketch:
```cpp
#include "MeMegaPi.h"
#define GearRatio 75
const byte interruptPin =18;    
const byte NE1=31;                 
long count=0;
unsigned long time;
unsigned long last_time;
MeMegaPiDCMotor motor1(PORT1B);   
uint8_t motorSpeed = 100;
void setup()
{
    pinMode(interruptPin, INPUT_PULLUP);
    pinMode(NE1, INPUT);
    attachInterrupt(digitalPinToInterrupt(interruptPin), blink,RISING);   
    Serial.begin(9600);   
}
void loop()
{
    motor1.run(motorSpeed);       // value: between -255 and 255
    time =millis(); 
    if(time-last_time>2000)    
    {
          Serial.println((count / GearRatio) / 8);
          last_time=time;
   }
}
void blink()
{
    if (digitalRead(NE1)>0)   
    count++;
    else
    count--;
}
```

---

Well, that was a frustrating experience. Remember, if you're developing something for anyone else (especially developers) to use, please make sure you document everything, and make that documentation searchable or something; it's really difficult to use a product without the proper documentation.

Until next time.

Happy coding,

CodingIndex
