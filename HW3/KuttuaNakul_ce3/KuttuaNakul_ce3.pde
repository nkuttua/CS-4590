import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions

ControlP5 p5;
SamplePlayer music;
SamplePlayer msg1;
SamplePlayer msg2;

//Gain UGen to control SamplePlayer volume
Gain masterGain;
Gain musicGain;

//Glide Ugens control the SamplePlayer
Glide masterGainGlide;
Glide musicGainGlide;
Glide filterGlide;

//Filter will swap between ducking
BiquadFilter duckFilter;
float HP_CUTOFF = 5000.0;

//end global variables

//runs once when the Play button above is pressed
void setup() {
  
  size(300, 300); //size(width, height) must be the first line in setup()
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions
  
  p5 = new ControlP5(this);
  
  //EndListener to un-duck
  Bead endListener = new Bead() {
     public void messageReceived(Bead message) {
        SamplePlayer sp = (SamplePlayer) message;
        
        filterGlide.setValue(10.0);
        
        musicGainGlide.setValue(1.0);
        
        sp.pause(true);
     }
  };
  
  music = getSamplePlayer("intermission.wav");
  msg1 = getSamplePlayer("CSR1.wav");
  msg2 = getSamplePlayer("CSR2.wav");
  
  msg1.setEndListener(endListener);
  msg2.setEndListener(endListener);
  
  //loop
  music.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  
  msg1.pause(true);
  msg2.pause(true);
  
  //Gain and Glide used to duck music by dec Gain/vol
  musicGainGlide = new Glide(ac, 1, 500); //last num is milisecond delay
  musicGain = new Gain(ac, 1, musicGainGlide);
  
  //create the master Gain and Glide Ugens
  masterGainGlide = new Glide(ac, 1, 500); //last num is milisecond delay
  masterGain = new Gain(ac, 1, masterGainGlide);
  
  //Biquad and cutoff filter Glide to duck music by filtering
  filterGlide = new Glide(ac, 10.0, 500); //last num is milisecond delay
  duckFilter = new BiquadFilter(ac, BiquadFilter.HP, filterGlide, 0.5);
  
  //create the Ugen graph
  //connect the music to the filter
  duckFilter.addInput(music);
  //connect the filter to the musicGain
  musicGain.addInput(duckFilter);
  
  //connect musicGain to masterGain
  masterGain.addInput(musicGain);
  
  //connect to masterGain
  masterGain.addInput(msg1);
  masterGain.addInput(msg2);
  
  //output
  ac.out.addInput(masterGain);
  
  //Create a slider for volume   
  p5.addSlider("GainSlider")
    .setPosition(80, 150)
    .setSize(30, 100)
    .setRange(0, 100)
    .setValue(30.0)
    .setLabel("Volume");
  
  
  //Create the Voice 1 Button
  p5.addButton("VoiceOne")
     .setPosition(20, 180)
     .setSize(50, 30)
     .setLabel("Voice 1");
     
  //Create the Voice 2 Button
  p5.addButton("VoiceTwo")
     .setPosition(20, 220)
     .setSize(50, 30)
     .setLabel("Voice 2");
     
  ac.start();
                  
}

public void VoiceOne() {
   msg2.pause(true);
   
   filterGlide.setValue(HP_CUTOFF);
   
   musicGainGlide.setValue(0.75);
   
   msg1.setToLoopStart();
   msg1.start();
}

public void VoiceTwo() {
   msg1.pause(true);
   
   filterGlide.setValue(HP_CUTOFF);
   
   musicGainGlide.setValue(0.75);
   
   msg2.setToLoopStart();
   msg2.start();
}

public void GainSlider(float value) {
  masterGainGlide.setValue(value / 100.0);
}

void draw() {
  background(0);  //fills the canvas with black (0) each frame
}
