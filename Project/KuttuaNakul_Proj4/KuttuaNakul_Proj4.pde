import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

//ControlP5 - for user interface controls
ControlP5 p5;

//SamplePlayers (sounds)
SamplePlayer temp;
SamplePlayer chew;
SamplePlayer move;
SamplePlayer hot;
SamplePlayer cold;
SamplePlayer checkpoint;
SamplePlayer leftchew;
SamplePlayer rightchew;
SamplePlayer clear;
SamplePlayer caution;
SamplePlayer danger;
SamplePlayer stop;
SamplePlayer stopactivity;

//Glides
Glide gainGlideTemp;
Glide gainGlideChew;
Glide gainGlideMove;
Glide masterGlide;

//Glides for Pitch
Glide cautionPitch;
Glide dangerPitch;
Glide stopPitch;

//Gain UGen to control SamplePlayer volume
Gain masterGainTemp;
Gain masterGainChew;
Gain masterGainMove;
Gain masterGain;

//Variables for data manipulation
float temperatureLevel;
float chewingSuccessRate;
float moveDangerLevel;
boolean tempActive;
boolean chewActive;
boolean moveActive;

//end global variables

//runs once when the Play button above is pressed
void setup() {
  
  size(875, 400); //size(width, height) must be the first line in setup()
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions
  p5 = new ControlP5(this);
  
  gainGlideTemp = new Glide(ac, 1, 1);
  gainGlideChew = new Glide(ac, 1, 1);
  gainGlideMove = new Glide(ac, 1, 1);
  masterGlide   = new Glide(ac, 1, 1);
  
  masterGainTemp = new Gain(ac, 1, gainGlideTemp);
  masterGainChew = new Gain(ac, 1, gainGlideChew);
  masterGainMove = new Gain(ac, 1, gainGlideMove);
  masterGain     = new Gain(ac, 1, masterGlide);
  
  temp = getSamplePlayer("temp.wav");
  chew = getSamplePlayer("chew.wav");
  move = getSamplePlayer("move.wav");
  
  hot = getSamplePlayer("hot.wav");
  cold = getSamplePlayer("cold.wav");
  checkpoint = getSamplePlayer("checkpoint.wav");
  
  leftchew = getSamplePlayer("leftchew.wav");
  rightchew = getSamplePlayer("rightchew.wav");
  
  clear = getSamplePlayer("clear.wav");
  caution = getSamplePlayer("caution.wav");
  danger = getSamplePlayer("danger.wav");
  stop = getSamplePlayer("stop.wav");
  
  stopactivity = getSamplePlayer("stopactivity.wav");
  
  temp.pause(true);
  chew.pause(true);
  move.pause(true);
  
  hot.pause(true);
  cold.pause(true);
  checkpoint.pause(true);
  
  leftchew.pause(true);
  rightchew.pause(true);
  
  clear.pause(true);
  caution.pause(true);
  danger.pause(true);
  stop.pause(true);
  
  stopactivity.pause(true);
  
  masterGainTemp.addInput(temp);
  masterGainTemp.addInput(hot);
  masterGainTemp.addInput(cold);
  masterGainTemp.addInput(checkpoint);
  
  masterGainChew.addInput(chew);
  masterGainChew.addInput(leftchew);
  masterGainChew.addInput(rightchew);
  masterGainChew.addInput(checkpoint);
  
  masterGainMove.addInput(move);
  masterGainMove.addInput(clear);
  masterGainMove.addInput(caution);
  masterGainMove.addInput(danger);
  masterGainMove.addInput(stop);
  
  masterGain.addInput(masterGainTemp);
  masterGain.addInput(masterGainChew);
  masterGain.addInput(masterGainMove);
  masterGain.addInput(stopactivity);
  
  ac.out.addInput(masterGain);

  p5.addButton("Temp")
     .setPosition(525,10)
     .setSize(80,30)
     .setLabel("Temperature")
     .activateBy((ControlP5.RELEASE));
     
  p5.addSlider("TempSlider")
    .setPosition(620, 10)
    .setSize(120, 30)
    .setRange(0, 120)
    .setValue(70)
    .setLabel("Temp Slider");
     
  p5.addButton("Chew")
     .setPosition(525,60)
     .setSize(80,30)
     .setLabel("Chew")
     .activateBy((ControlP5.RELEASE));
     
  p5.addSlider("ChewSlider")
    .setPosition(620, 60)
    .setSize(120, 30)
    .setRange(0, 100)
    .setValue(50)
    .setLabel("Chew Slider");
     
  p5.addButton("Move")
     .setPosition(525,110)
     .setSize(80,30)
     .setLabel("Moving")
     .activateBy((ControlP5.RELEASE));
    
  p5.addSlider("MoveSlider")
    .setPosition(620, 110)
    .setSize(120, 30)
    .setRange(0, 10)
    .setValue(0)
    .setLabel("Move Slider");
    
  p5.addSlider("Volume")
    .setPosition(820, 10)
    .setSize(30, 120)
    .setRange(0, 1)
    .setValue(50)
    .setNumberOfTickMarks(11)
    .setLabel("Volume");
    
  p5.addButton("Stop")
     .setPosition(525,160)
     .setSize(80,30)
     .setLabel("Stop Activity")
     .activateBy((ControlP5.RELEASE));
  
  ac.start();
                  
}

public void Temp(int value) {
   println("Temperature Button Pressed");
   temp.setPosition(0);
   temp.start();
   tempActive = true;
   chewActive = false;
   moveActive = false;
}

public void TempSlider(float value) {
  println("Temp slider moved: ", value);
  temperatureLevel = value;
  if (tempActive) {
    if (temperatureLevel <= 32) {
      
      checkpoint.pause(true);
      hot.pause(true);
      cold.setPosition(0);
      cold.start();
      cold.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
      
    } else if (temperatureLevel >= 32 && temperatureLevel < 90) {
      
      cold.pause(true);
      hot.pause(true);
      checkpoint.setPosition(0);
      checkpoint.start(); 
      
    } else if (temperatureLevel >= 90) {
      
      checkpoint.pause(true);
      cold.pause(true);
      hot.setPosition(0);
      hot.start(); 
      hot.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
      
    }
  }
}

public void Chew(int value) {
   println("Chew Button Pressed");
   chew.setPosition(0);
   chew.start();
   chewActive = true;
   tempActive = false;
   moveActive = false;
}

public void ChewSlider(float value) {
  println("Chew slider moved: ", value);
  chewingSuccessRate = value;
  if (chewActive) {
    if (chewingSuccessRate < 33.33) {
      
      checkpoint.pause(true);
      rightchew.pause(true);
      leftchew.setPosition(0);
      leftchew.start();
      leftchew.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
      
   } else if (chewingSuccessRate >= 33.33 && chewingSuccessRate < 66.66) {
     
      leftchew.pause(true);
      rightchew.pause(true);
      checkpoint.setPosition(0);
      checkpoint.start();
      
   } else if (chewingSuccessRate >= 66.66) {
     
      leftchew.pause(true);
      checkpoint.pause(true);
      rightchew.setPosition(0);
      rightchew.start();
      rightchew.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
      
   }
  }
}

public void Move(int value) {
   println("Move Button Pressed");
   move.setPosition(0);
   move.start();
   moveActive = true;
   tempActive = false;
   chewActive = false;
}

public void MoveSlider(float value) {
  println("Move slider moved: ", value);
  moveDangerLevel = value;
  if (moveActive) {
    if (moveDangerLevel == 0) {
      
      caution.pause(true);
      danger.pause(true);
      stop.pause(true);
      clear.setPosition(0);
      clear.start();
      
   } else if (moveDangerLevel <= 3) {
     
      clear.pause(true);
      danger.pause(true);
      stop.pause(true);
      caution.setPosition(0);
      caution.start();
      cautionPitch = new Glide(ac, 1.1);
      caution.setPitch(cautionPitch);
      caution.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
      
   } else if (moveDangerLevel > 3 && moveDangerLevel <= 6) {
     
      clear.pause(true);
      caution.pause(true);
      stop.pause(true);
      danger.setPosition(0);
      danger.start();
      dangerPitch = new Glide(ac, 1.2);
      danger.setPitch(dangerPitch);
      danger.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
      
   } else if (moveDangerLevel > 6) {
     
      clear.pause(true);
      caution.pause(true);
      danger.pause(true);
      stop.setPosition(0);
      stop.start();
      stopPitch = new Glide(ac, 1.3);
      stop.setPitch(stopPitch);
      stop.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
      
   }
  }
}

public void Volume(float value) {
  masterGlide.setValue(value * 2);
  println(masterGlide.getValue());
}

public void Stop() {
   temp.pause(true);
   chew.pause(true);
   move.pause(true);
   hot.pause(true);
   cold.pause(true);
   checkpoint.pause(true);
   leftchew.pause(true);
   rightchew.pause(true);
   clear.pause(true);
   caution.pause(true);
   danger.pause(true);
   stop.pause(true);
   tempActive = false;
   chewActive = false;
   moveActive = false;
   stopactivity.setPosition(0);
   stopactivity.start();
}

void drawWaveform() {
  fill (0, 32, 0, 32);
  rect (0, 0, width, height);
  stroke (32);
  for (int i = 0; i < 11 ; i++){
    line (0, i * 75, width, i * 75);
    line (i * 75 + 25, 0, i * 75 + 25, height);
  }
  stroke (0);
  line (width / 2, 0, width / 2, height);
  line (0, height / 2, width, height / 2);
  stroke (128, 255, 128);
  int crossing = 0;
  // draw the waveforms so we can see what we are monitoring
  for(int i = 0; i < ac.getBufferSize() - 1 && i < width + crossing; i++) {
    if (crossing == 0 && ac.out.getValue(0, i) < 0 && ac.out.getValue(0, i + 1) > 0) crossing=i;
    if (crossing != 0) {
      line( i - crossing, height / 2 + ac.out.getValue(0, i) * 300, i + 1 - crossing, height / 2 + ac.out.getValue(0, i + 1)*300 );
    }
  }
  
  fill (0);
  stroke (0);
  rect (500, 0, 375, 200);
}

void draw() {
  drawWaveform();
}
