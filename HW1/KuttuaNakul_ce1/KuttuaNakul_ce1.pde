import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions

PImage bg; //PImage - used for adding in a custom image for the background

//ControlP5 - for user interface controls
ControlP5 p5;

//SamplePlayer UGen for playing a WAV file
SamplePlayer sp;

//Gain UGen to control SamplePlayer volume
Gain masterGain;

Glide gainGlide;
Glide cutoffGlide;

BiquadFilter lpFilter;

//end global variables

//runs once when the Play button above is pressed
void setup() {
  
  size(300, 300); //size(width, height) must be the first line in setup()
  bg = loadImage("bgImage.jpeg");
  
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions
  
  p5 = new ControlP5(this);
  
  sp = getSamplePlayer("The-King.wav");
  sp.pause(true);
  
  cutoffGlide = new Glide(ac, 1500.0, 50);
  lpFilter = new BiquadFilter(ac, BiquadFilter.LP, cutoffGlide, 0.5f);
  
  gainGlide = new Glide(ac, 1, 50); //last num is milisecond delay
  
  masterGain = new Gain(ac, 1, gainGlide);
  masterGain.addInput(sp);
  
  lpFilter.addInput(masterGain);
  
  ac.out.addInput(lpFilter);
  
  //Create the Play Button
  p5.addButton("Play")
     .setPosition(20,180)
     .setSize(80,30)
     .setLabel("Play/Pause Music")
     .activateBy((ControlP5.RELEASE));
     
  //Create a slider for frequency (how clear it sounds to us)
  p5.addSlider("CutoffSlider")
    .setPosition(220, 110)
    .setSize(30, 100)
    .setRange(100, 5000)
    .setValue(5000)
    .setLabel("Cutoff Freq");
     
  //Create a slider for volume   
  p5.addSlider("GainSlider")
    .setPosition(120, 110)
    .setSize(30, 100)
    .setRange(0, 100)
    .setValue(20)
    .setLabel("Gain Slider (Volume)");
  
  ac.start();
                  
}

public void Play(int value) {
   println("Play Button Pressed");
   sp.setToLoopStart();
   sp.start();
   sp.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
}

public void GainSlider(float value) {
  println("Gain slider moved: ", value);
  gainGlide.setValue(value / 100.0);
}

public void CutoffSlider(float value) {
  println("Cutoff slider moved: ", value);
  cutoffGlide.setValue(value);
}


void draw() {
  //background(0);  //fills the canvas with black (0) each frame
  background(bg);   // I put my own background image here
}
