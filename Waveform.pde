
public class Waveform {
  private float[] samples;
  private float TTL;
  private int amplitude, radius, timeToLive;
  private color hsb;
  
  public Waveform(float[] samples, int amplitude, int radius, int TTL) {
    this.samples = samples;
    this.TTL = this.timeToLive = TTL;
    this.amplitude = amplitude;
    this.radius = radius;
    this.hsb = color(random(0,360), 100, 100);
  }

  public void render() {
    noFill();
    strokeWeight(4);
    stroke(hsb, map(TTL, timeToLive, 0, 255, 0)); // alpha blending, fade out w/ respect to TTL
   
    if (debug) {  // draw the waveform as one single, homogenous shape
      beginShape();
      for (int curr=0; curr<samples.length; curr++) {
        float theta = TWO_PI * ((float) curr/samples.length);
        float magnitude = (amplitude * samples[curr]) + radius;
        vertex(width/2 + (cos(theta) * magnitude), height/2 + (sin(theta) * magnitude));
      }
      endShape();
    }
    else {  // draw the waveform as many discrete, connected line segments
      for (int curr=0, next=0; next<samples.length; curr=next++) {  
        // segment starting coordinate
        float theta = TWO_PI * ((float) curr/samples.length);      // point direction, in radians: (% progress traveling around the circle couter-clockwise)
        float magnitude = (amplitude * samples[curr]) + (radius);  // point distance from center of circle
        PVector segmentStart = new PVector(width/2 + (cos(theta) * magnitude), height/2 + (sin(theta) * magnitude));

        // segment terminal coordinate
        theta = TWO_PI * ((float) next/samples.length);
        magnitude = (amplitude * samples[next]) + (radius);
        PVector segmentEnd = new PVector(width/2 + (cos(theta) * magnitude), height/2 + (sin(theta) * magnitude));

        // connect points
        line(segmentStart.x, segmentStart.y, segmentEnd.x, segmentEnd.y);
      }
    }
  }
 
  // expand the waveform: increases radius, fades color value, decrements time-to-live.
  public float radiate() {
    radius += 16; // (60/frameRate) * 8;
    return --TTL;
  }
}
