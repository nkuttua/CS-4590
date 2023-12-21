// FFT_01.pde
// This example is based in part on an example included with
// the Beads download originally written by Beads creator
// Ollie Bown. It draws the frequency information for a
// sound on screen.
import beads.*;
import controlP5.*;

Gain masterGain;

Glide cutoffGlide;
BiquadFilter filter;

Reverb reverb;

UGen micInput;
SamplePlayer player;

ControlP5 p5;
PowerSpectrum ps;

boolean micOn = false;
boolean reverbOn = false;

color fore = color(255, 255, 255);
color back = color(0,0,0);

void setup()
{

 size(1000,600);
 p5 = new ControlP5(this);
 ac = new AudioContext();

 // set up a master gain object
 masterGain = new Gain(ac, 2, 0.3);
 ac.out.addInput(masterGain);

 // load up a sample included in code download
 player = null;
 try
 {
 // Load up a new SamplePlayer using an included audio
 // file.
 
 player = getSamplePlayer("soundclip.wav",false);
 player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
 // connect the SamplePlayer to the master Gain
 }
 catch(Exception e)
 {
 // If there is an error, print the steps that got us to
 // that error.
 e.printStackTrace();
 }
 // In this block of code, we build an analysis chain
 // the ShortFrameSegmenter breaks the audio into short,
 // discrete chunks.
 ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
 //sfs.setChunkSize(64);
 sfs.addInput(ac.out);

 // FFT stands for Fast Fourier Transform
 // all you really need to know about the FFT is that it
 // lets you see what frequencies are present in a sound
 // the waveform we usually look at when we see a sound
 // displayed graphically is time domain sound data
 // the FFT transforms that into frequency domain data
 FFT fft = new FFT();
 // connect the FFT object to the ShortFrameSegmenter
 sfs.addListener(fft);

 // the PowerSpectrum pulls the Amplitude information from
 // the FFT calculation (essentially)
 ps = new PowerSpectrum();
 // connect the PowerSpectrum to the FFT
 fft.addListener(ps);
 // list the frame segmenter as a dependent, so that the
 // AudioContext knows when to update it.
 ac.out.addDependent(sfs);
 
 cutoffGlide = new Glide(ac, 1500.0, 50);
 filter = new BiquadFilter(ac, BiquadFilter.AP, cutoffGlide, 0.5f);
 //add player output to filter
 filter.addInput(player);
 //add output of filter to the gain
 masterGain.addInput(filter);
 
 reverb = new Reverb(ac);
 reverb.setSize(0.01);
 reverb.setDamping(0.1);
 reverb.setEarlyReflectionsLevel(0.1);
 
 micInput = ac.getAudioInput();
 
 //Button to control low pass fiter
 p5.addButton("LowPassFilter")
   .setPosition(895, 0)
   .setSize(100, 20)
   .setLabel("Low Pass Filter");
   
 //Button to control high pass fiter
 p5.addButton("HighPassFilter")
   .setPosition(895, 25)
   .setSize(100, 20)
   .setLabel("High Pass Filter");
   
 //Button to control no fiter
 p5.addButton("NoFilter")
   .setPosition(895, 50)
   .setSize(100, 20)
   .setLabel("No Filter");
   
 //Button to control band pass fiter
 p5.addButton("BandPassFilter")
   .setPosition(895, 75)
   .setSize(100, 20)
   .setLabel("Band Pass Filter");
   
 //Button to control reverb
 p5.addButton("Reverb")
   .setPosition(895, 125)
   .setSize(100, 20)
   .setLabel("Reverb Toggle");
   
 //Button to control mic
 p5.addButton("Mic")
   .setPosition(895, 175)
   .setSize(100, 20)
   .setLabel("Mic Toggle");
   
 //Slider to control cutoff freq
 p5.addSlider("CutoffSlider")
   .setPosition(695, 100)
   .setSize(200, 20)
   .setLabel("Cutoff Frequency");
   
 //Slider to control damping
 p5.addSlider("Damping")
   .setPosition(695, 150)
   .setSize(200, 20)
   .setRange(0.0, 1.0)
   .setValue(0.5)
   .setLabel("Damping");
 
 // start processing audio
 ac.start();
}

// Button Handler - NoFilter - for toggling filter off
public void NoFilter() {
  println("no filter button pressed");
  filter.setType(BiquadFilter.AP);
}

// Button Handler - LowPassFilter - for turning on low pass filter
void LowPassFilter() {
  println("low pass filter button pressed");
  filter.setType(BiquadFilter.LP);
}

// Button Handler - HighPassFilter - for turning on high pass filter
void HighPassFilter() {
  println("high pass filter button pressed");
  filter.setType(BiquadFilter.HP);
}

void MicOn() {
  if (micOn) {
    micOn = false;
  } else {
    micOn = true; 
  }
  
  if (micOn) {
    filter.clearInputConnections();
    filter.addInput(micInput);
  } else {
    filter.clearInputConnections();
    filter.addInput(player); 
  }
  
}

void Reverb() {
   if (reverbOn) {
     reverbOn = false;
     reverb.clearInputConnections();
     masterGain.clearInputConnections();
     masterGain.addInput(filter);
   } else {
     reverbOn = true;
     masterGain.clearInputConnections();
     reverb.addInput(filter);
     masterGain.addInput(reverb);
   }
}

void BandPassFilter() {
  println("band pass filter button pressed");
  filter.setType(BiquadFilter.BP_SKIRT);
}

public void CutoffSlider(float value) {
   println("cut off slider pressed");
   cutoffGlide.setValue(value);
}

public void Damping(float value) {
   reverb.setDamping(value); 
}

// In the draw routine, we will interpret the FFT results and
// draw them on screen.

void draw()
{
 background(back);
 stroke(fore);

 // The getFeatures() function is a key part of the Beads
 // analysis library. It returns an array of floats
 // how this array of floats is defined (1 dimension, 2
 // dimensions ... etc) is based on the calling unit
 // generator. In this case, the PowerSpectrum returns an
 // array with the power of 256 spectral bands.
 float[] features = ps.getFeatures();

 // if any features are returned
 if(features != null)
 {
 // for each x coordinate in the Processing window
 for(int x = 0; x < width; x++)
 {
 // figure out which featureIndex corresponds to this x-
 // position
 int featureIndex = (x * features.length) / width;
 // calculate the bar height for this feature
 int barHeight = Math.min((int)(features[featureIndex] *
 height), height - 1);
 // draw a vertical line corresponding to the frequency
 // represented by this x-position
 line(x, height, x, height - barHeight);
 }
 }
}
