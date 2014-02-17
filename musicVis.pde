import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;
import java.util.List;
import java.io.*;

/*  @author Jackson Westeen
    http://jacksonwesteen.com
 */

// audio
public Minim minim;
public AudioPlayer player;
public int trackNum;
public String[] songs;

// visual
Visulization active, missionControl, waveGenerator, blockGenerator;
boolean debug;

// controls
void keyPressed() {
  switch (keyCode) {
    case '1':
    frameRate(60);
      active = missionControl;
      break;
    case '2':
    frameRate(30);
      active = waveGenerator;
      break;
    case '3':
    frameRate(60);
      active = blockGenerator;
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
    case 'D':
      debug = !debug;
      println("debug " + (debug ? "ON" : "OFF"));
      break;
  }
}

void setup() {
  println("starting...");
  println("working directory: " + this.sketchPath);
  
  // environment
  size(1280, 720, P3D);
  colorMode(HSB, 360, 100, 100);
  smooth(8);
  rectMode(CORNERS);
  
  // testing
  debug = true;
  
  // minim + songs
  minim = new Minim(this);
  songs = new File(dataPath("")).list();
  trackNum = (int) random(0, songs.length);
  
  // create a reference for player, and...
  // "play that fuckin' track!"
  play();
  
  // display modes
  missionControl = new MissionControl();
  waveGenerator = new WaveGenerator();
  blockGenerator = new BlockGenerator();
  active = missionControl;
}

void draw() {
  active.update();
}

void play() {
  try { 
    player = minim.loadFile(songs[trackNum], 2048);
    player.play();
    println("loaded track: " + songs[trackNum]); 
  } catch (Exception e) {
    if (songs.length > 0) {
      println("Could not load file, \"" + songs[trackNum] + "\" :|");
    } else if (songs.length == 0) {
      println("whoa! no songs in " + dataPath(""));
    } else {
      println("Uncaught exception " + e.getMessage()); 
    }
    System.exit(1);
  }
}

void stop() {
  try {
    player.close();
    minim.stop();
  } catch (Exception e) {
    println("something awful happened while stopping playback!\n" + e.getMessage()); 
  }
}

