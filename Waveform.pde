
public class Waveform {
  private float[] samples;
  public float TTL;
  public int amplitude, radius, timeToLive;
  public color hsb;
  
  public Waveform(float[] samples, int amplitude, int radius, int TTL) {
    this.samples = samples;
    this.amplitude = amplitude;
    this.radius = radius;
    this.TTL = this.timeToLive = TTL;  // init
    this.hsb = color(random(0,360), 100, 100);
  }

  public void render() {
    noFill();
    strokeWeight(4);
    stroke(hsb, map(TTL, timeToLive, 0, 255, 0)); // alpha blending, fade out w/ respect to TTL
   
   // draw the waveform as one single, homogenous shape
    beginShape();
    for (int i=0; i<samples.length; i++) {
      float theta = TWO_PI * ((float) i/samples.length);
      float magnitude = (amplitude * samples[i]) + radius;
      vertex(width/2 + (cos(theta) * magnitude), height/2 + (sin(theta) * magnitude));
    }
    endShape();
  }
 
  // expand the waveform, return its remaining lifespan
  // increases radius, decrements time-to-live.
  public float radiate(float step) {
    radius += step;
    return --TTL;
  }
}
