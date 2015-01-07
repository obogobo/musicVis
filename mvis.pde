import ddf.minim.*;
import ddf.minim.analysis.*;
import java.util.List;
import java.io.*;

/*  @author Jackson Westeen
    http://jacksonwesteen.com
 */

// audio
public Minim minim;
public AudioPlayer player;
public BassDetect bassDetect;
public int trackNum;
public String[] songs;

// visual
Visulization active, missionControl, waveGenerator, blockGenerator, terrainGenerator, tapestryGenerator;
boolean debugMode;
boolean dubMode;
boolean speedMode;
boolean tranceMode;
boolean cruiseMode;
boolean newColor;
boolean warningsOn;
boolean demoMode;
float depth;

// controls
void keyReleased() {
  switch (keyCode) {
    case '1':
      active = missionControl;
      break;
    case '2':
      active = waveGenerator;
      break;
    case '3':
      active = blockGenerator;
      break;
    case '4':
      active = terrainGenerator;
      break;
    case '5':
      active = tapestryGenerator;
      break;
    case ' ':
      stop();
      trackNum = (++trackNum % songs.length); // next track
      play(); 
      break;
    case LEFT:
      stop();
      trackNum = ((--trackNum + songs.length) % songs.length); // prev track
      play();
      break;
    case 'D':
      debugMode = !debugMode;
      println("debugMode: " + (debugMode ? "ON" : "OFF"));
      break;
    case 'S':
      dubMode = !dubMode;
      println("dubMode: " + (dubMode ? "ENABLED" : "DISABLED"));
      break;
    case 'E':
      tranceMode = !tranceMode;
      println("traceMode: " + (tranceMode ? "ENABLED" : "DISABLED"));
      break;
    case 'A':
      speedMode = !speedMode;
      println((!speedMode ? "" : "un") + "throttling framerate...");
      frameRate((!speedMode ? 60 : 999));
      break;
    case 'C':
      cruiseMode = !cruiseMode;
      println((cruiseMode ? "smooth sailing" : "buckle up"));
      break;
    case 'X':
      newColor = true;
      println("fresh paint!");
      break;
  }
}

void setup() {  
  // environment
  size(720, 720, P3D);
  depth = (width + height + 500);
  colorMode(HSB, 360, 100, 100);
  smooth(8);
  
  // testing
  debugMode = false;
  dubMode = false;
  tranceMode = false;
  speedMode = false;
  cruiseMode = false;
  warningsOn = false;
  demoMode = true;
  
  // minim + songs
  minim = new Minim(this);
  songs = new File(dataPath("")).list();
  trackNum = (int) random(0, songs.length);
  
  println("starting...");
  println("working directory: " + this.sketchPath);
  println("data directory: " + dataPath(""));
  
  // "play that fuckin' track!"
  play();
  
  // display modes
  missionControl = new MissionControl();
  waveGenerator = new WaveGenerator();
  blockGenerator = new BlockGenerator();
  terrainGenerator = new TerrainGenerator();
  tapestryGenerator = new TapestryGenerator();
  active = tapestryGenerator;
}

void draw() {
  camera();
  noFill();
  noStroke();
  rectMode(CORNERS);
  
  // for mixing 2D/3D modes
  if (active == blockGenerator && tranceMode) {
    camera(width/2.0, height/2.0, depth / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0,  0, 1, 0);
    fill(0, 50);
    rectMode(CENTER);
    rect(width/2.0, height/2.0, ((float) width / (float) height) * 2*depth, 2*depth);
  } else if (tranceMode) {
    fill(0, 65);
    rect(0, 0, width, height);
  } else {
    background(0); 
  }
  
  // render the active visual
  active.update();
  
  // low framerate warning
  if (warningsOn && frameRate < 55) {
    fill(0,100,100);
    rect(0, 0, width, height);
  }
}

void play() {
  try { 
    if (demoMode) {
      dubMode = true;
      tranceMode = true;
      //player = minim.loadFile("Figure 8 (Xilent Remix).mp3", 2048);
      //player.cue(81500);
      
      player = minim.loadFile("01. Xilent - Choose Me II (Original Mix).mp3", 2048);
      // player.cue(88000);
    } else {
      player = minim.loadFile(songs[trackNum], 2048);
      println("loaded track: " + songs[trackNum]); 
    }
    
    player.play();
    
    // initially null, set to null on stop()
    // thread runs while song is playing
    if (bassDetect == null) {
      bassDetect = new BassDetect();
      bassDetect.start();
    }    
  } catch (Exception e) {
    println(e.toString());
    if (songs.length > 0) {
      println("could not load file, \"" + (demoMode ? "***DEMO MODE***" : songs[trackNum]) + "\" :|");
    } else {
      println("whoa! no songs in " + dataPath(""));
    }
    System.exit(1);
  }
}

void stop() {
  try {
    player.close();
    minim.stop();
    
    bassDetect = null;
    System.gc();  // might as well try...
  } catch (Exception e) {
    println("something awful happened while stopping playback!\n" + e.getMessage()); 
  }
}
