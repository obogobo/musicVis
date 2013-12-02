import ddf.minim.*;
import ddf.minim.analysis.*;

/*
  @author Jackson Westeen
 */

Minim minim;
AudioSource active;
AudioPlayer player;
AudioInput input;
FFT fftSpec,
    fftBass;

// frequency analysis
float[] longWindow = new float[60*5]; // 60 frames * 5 seconds = 300 sample moving window
float[] shortWindow = new float[6];   // 1/10th second = 6 sample moving window
float kickAmount,
      barWidth,
      sliceArc;
int bassIndex,
    trebIndex;
    
// media
int trackNum;
String[] songs = {"04. This Time (Klaas Dub Remix).mp3",
                  "01 - Give life back to music.mp3",
                  "Nero - Must Be The Feeling (Delta Heavy Remix).mp3",
                  "Paradise (Glebstar Dubstep Remix).mp3",
                  "stardust_redux.mp3",
                  "01 Codec (Extended Mix).mp3",
                  "00 - Pumped Up Kicks (Butch Clancy Remix).mp3",
                  "01 - Try It Out (Neon Mix).mp3",
                  "01 Smells Like Teen Spirit.mp3",
                  "01 You Make Me.mp3",
                  "01-freeloader_(vocal_radio_mix)-wlm.mp3",
                  "02 - Chasing Summers (Original Mix).mp3",
                  "03 - A Reach For Glory.mp3",
                  "04 Crow Machine (Original Mix).mp3",
                  "08-bingo_players_-_rattle_(candyland_remix).mp3",
                  "Daybreak (GoPro HERO3 Edit).mp3",
                  "02 Beam Me Up (Kill Mode) (Radio Edit).mp3",
                  };

// ui components
ArrayList<Box> boxWorld;
ArrayList<Box> boxTombs;
PVector boxStep;
int visMode,
    box_size;
float box_roll;
boolean box_rolling,
        debug;

// audio-visual controls
void keyPressed() {
  switch (keyCode) {
    case '1':
      visMode = 0;
      break;
    case '2':
      visMode = 1;
      break;
    case ' ':
      stop();
      trackNum = (++trackNum % songs.length); // next track
      play();
      break;
    case RIGHT:
      if (player.position() <= player.length() - 500) {
        player.skip(500); // 500ms skip forward
      }
      break;
    case '0':
      stop();
      listen();
      break;
    case 'D':
      debug = !debug;
      break;
  }
}

void setup() {
  println("starting...");
  size(1280, 720, P3D);
  colorMode(HSB, 360, 100, 100);
  rectMode(CORNERS);
  smooth();
  
  // current display mode
  visMode = 0;
  
  // minim audio controls and analysis tools
  minim = new Minim(this);
  trackNum = int(random(0, songs.length));
  play(); // "play that fuckin' track! (...oh there it is)"

  fftSpec = new FFT(active.bufferSize(), active.sampleRate());
  fftBass = new FFT(active.bufferSize(), active.sampleRate());
  
  // number of "buckets" in the spectra
  fftSpec.logAverages(22, 2);
  fftBass.logAverages(22, 1);
  barWidth = width/fftSpec.avgSize();
  sliceArc = TWO_PI/fftSpec.avgSize();
  
  // boxes and parameters 
  boxWorld = new ArrayList<Box>();
  boxTombs = new ArrayList<Box>();
  boxStep = new PVector(0,0,2);
  box_size = 100;
  box_roll = 0;
  box_rolling = false;

  // these may need a bit of tweaking...
  bassIndex = 1;      // "bucket" considerd to resemble bass
  trebIndex = 5;      // "bucket" considered to resemble treble, not in use yet
  kickAmount = 0.1;   // pseudo "just noticeable difference"
  debug = true;
}

void draw() {
  switch (visMode) {  // visulization mode switch
  
  case 0: // mission control
    background(0);
    
    // perform a forward FFT on the samples in active's mix buffer
    fftSpec.forward(active.mix);
    
    // draw the left & right channel waveforms, the values returned by mix.get()
    // will be between -1 and 1, so we need to scale them up to see the waveform
    stroke(255);
    strokeWeight(2);
    for (int i=0; i<active.bufferSize()-1; i++) {
      float x1 = map(i, 0, active.bufferSize(), 0, width);
      float x2 = map(i+1, 0, active.bufferSize(), 0, width);
      line(x1, 50 + active.left.get(i)*50, x2, 50 + active.left.get(i+1)*50);
      line(x1, 150 + active.right.get(i)*50, x2, 150 + active.right.get(i+1)*50);
      //stroke(map(i,0,player.bufferSize()-1,0,360),90,90);
    }
    
    // wrap the logarithmic averages around a parametric circle O_o
    if (debug) {
      for (float t=0; t<TWO_PI; t+=(TWO_PI/fftSpec.avgSize())) {
        noStroke();
        fill(map(t, 0, TWO_PI, 0, 360), 90, 90);
        beginShape(TRIANGLE_STRIP); // better fill
        for (float u=t; u<(t+(TWO_PI/fftSpec.avgSize())); u+=0.02) {
          float x = cos(u) * fftSpec.getAvg(int(map(t, 0, TWO_PI, 0, fftSpec.avgSize())));
          float y = sin(u) * fftSpec.getAvg(int(map(t, 0, TWO_PI, 0, fftSpec.avgSize())));
          vertex(width/2, height/2);
          vertex((width/2)+x, (height/2)+y);
        }
        endShape(CLOSE);
      }
    } else {
      for (int t=0; t<fftSpec.avgSize(); t++) {
        float amplitude = fftSpec.getAvg(t),
              x1 = width/2 + cos(t * sliceArc) * amplitude,
              y1 = height/2 + sin(t * sliceArc) * amplitude,
              x2 = width/2 + cos((t+1) * sliceArc) * amplitude,
              y2 = height/2 + sin((t+1) * sliceArc) * amplitude;
        noStroke();
        fill(map(t, 0, fftSpec.avgSize()-1, 0, 360), 90, 90);
        triangle(x1, y1, x2, y2, width/2, height/2);
      }
    }
    
    // display the logarithmic averages as a standard equalizer -_-
    stroke(0);
    strokeWeight(1);
    for (int i=0; i<fftSpec.avgSize(); i++) {
      // draw a rectangle for each average
      fill(map(i, 0, fftSpec.avgSize()-1, 0, 360), 90, 90);
      rect(i*barWidth, height, i*barWidth + barWidth, height - fftSpec.getAvg(i));
    }
    break;
    
  case 1: // bass blocks
    background(61);
  
    // perform a forward FFT on the samples in active's mix buffer
    fftBass.forward(active.mix);

    // BEAT DETECTION - CALCULATE BASS THRESHOLD(s)
    // compute a moving average of the amplitude measured at the bassIndex, 
    // this can be thought of as the threshold required to register a "kick".
    float longThreshold = getAvg(longWindow),
          shortThreshold = getAvg(shortWindow),
          noiseThreshold = ((kickAmount * longThreshold > kickAmount * 100) ? (kickAmount * longThreshold) : (kickAmount * 100));
          
          // && (shortThreshold > (kickAmount * 100))
          // && (fftSpec.getAvg(bassIndex) > kickAmount))
    if ((shortThreshold >= longThreshold) && (shortThreshold > noiseThreshold)) {
      boxStep.z = 25;
    } 
    longWindow[frameCount % longWindow.length] = fftBass.getAvg(bassIndex);
    shortWindow[frameCount % shortWindow.length] = fftBass.getAvg(bassIndex);
    
    // draw lines, because MATH! << very useful when tweaking the beat detection
    if (debug) {
      strokeWeight(5);
      // WHITE = long "relative" threshold (5 second moving average)
      stroke(255);
      line(0, (height - longThreshold), width, (height - longThreshold));
      // GREEN = short punchy bass measure (1/10th second moving average)
      stroke(120, 90, 90);
      line(0, (height - shortThreshold), width, (height - shortThreshold));
      // BLUE = absolute lower bound (fixed)
      stroke(180, 90, 90);
      line(0, (height - noiseThreshold), width, (height - noiseThreshold));
    }
    
    // UPDATE VISUALS - MOVE THE BLOCKS
    // add the cubes! 40 max at any given time
    if (boxWorld.size() < 40) {
      boxWorld.add(new Box());
    }
    
    // translate and render 'em
    for (Box b : boxWorld) {
      b.render(boxStep);
      // garbage collect the off-screen cubes
      if (b.spot.x < -500 || b.spot.x > (width + 500)
          || b.spot.y < -500 || b.spot.y > (height + 500)
          || b.spot.z > (box_size * 2)) {
        boxTombs.add(b);
      }
    }
    boxWorld.removeAll(boxTombs);
    boxTombs.clear();
    
    // return to baseline (not bassline!) cube speed
    boxStep.z = 2;
    break;
  }
}

public class Box {
  public PVector spot;
  public color hsb;

  public Box() {
    // spawn at random position
    spot = new PVector(random(-500, width + 500),  // horizontal position
                       random(-250, height + 250), // vertical position
                       random(-2500, -1500));      // distance into screen
    hsb = color(180, 90, 90);
  }

  public void render(PVector step) {
    stroke(hsb);
    strokeWeight(1);
    
    // transform each cube individually    
    spot.add(step);
    pushMatrix();
    translate(spot.x, spot.y, spot.z);
    if (box_rolling) {
      box_roll = ((box_roll + 0.1) % 360);
      rotateY(radians(box_roll));
      rotateZ(radians(box_roll));
    }
    fill(0);
    box(box_size);
    popMatrix();
  }
}


void play() {
  super.start(); // Java's painting thread?
  try { 
    player = minim.loadFile(songs[trackNum], 2048); 
  } catch (Exception e) {
    println("Could not load file " + songs[trackNum] + ":|");
    System.exit(1);
  }
  println("loaded track: " + songs[trackNum]);
  player.play();
  active = player;
}


void listen() {
  super.start(); // Java's painting thread?
  try { 
    // get a line in from Minim, default bit depth is 16
    input = minim.getLineIn(Minim.STEREO, 2048);
  } catch (Exception e) {
    println("Could not open input stream :|");
    System.exit(1);
  }
  println("i can hear you...");
  active = input;
}


void stop() {
  active.close(); // always close Minim audio classes when you are done with them
  minim.stop();   // always stop Minim before exiting
  super.stop();
  
  // there's a bug higher up the pipe somewhere...
  if (active == input) {
    System.exit(0); 
  }
}


// normalize the bass window
float getAvg(float[] vals) {
   int n;
   float sum=0;
   for (n=0; n<vals.length; n++)
     sum += vals[n];
   return sum/n; 
}

