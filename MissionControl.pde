
public class MissionControl extends Visulization {
  private float barWidth, sliceRad;
  
  public MissionControl() {
      super();
      
      // params
      barWidth = width/super.fft.avgSize();
      sliceRad = TWO_PI/super.fft.avgSize();
  }
  
  @Override
  public void update() {
    frame.setTitle(floor(frameRate) + " fps // " + "T-" + (player.length() - player.position())); 
    
    // perform a forward FFT on the samples in active's mix buffer
    super.fft.forward(player.mix);
    
    // draw the left & right channel waveforms, the values returned by mix.get()
    // will be between -1 and 1, so we need to scale them up to see the waveform
    stroke(255);
    strokeWeight(3);
    for (int i=0; i<player.bufferSize()-1; i++) {
      float x1 = map(i, 0, player.bufferSize(), 0, width);
      float x2 = map(i+1, 0, player.bufferSize(), 0, width);
      line(x1, 50 + player.left.get(i)*50, x2, 50 + player.left.get(i+1)*50);
      line(x1, 150 + player.right.get(i)*50, x2, 150 + player.right.get(i+1)*50);
      //stroke(map(i,0,player.bufferSize()-1,0,360),90,90);
    }
    
    // wrap the FFT logarithmic averages around a parametric circle O_o
    if (debugMode) {
      for (float t=0; t<TWO_PI; t+=(TWO_PI/super.fft.avgSize())) {
        noStroke();
        fill(map(t, 0, TWO_PI, 0, 360), 100, 100);
        beginShape(TRIANGLE_STRIP); // better fill
        for (float u=t; u<(t+( TWO_PI/super.fft.avgSize())); u+=0.02) {
          float x = cos(u) * super.fft.getAvg(int(map(t, 0, TWO_PI, 0, super.fft.avgSize()))),
                y = sin(u) * super.fft.getAvg(int(map(t, 0, TWO_PI, 0, super.fft.avgSize())));
          vertex(width/2, height/2);
          vertex((width/2)+x, (height/2)+y);
        }
        endShape(CLOSE);
      }
    } else {
      for (int t=0; t<super.fft.avgSize(); t++) {
        float amplitude = super.fft.getAvg(t),
              x1 = width/2 + cos(t * sliceRad) * amplitude,
              y1 = height/2 + sin(t * sliceRad) * amplitude,
              x2 = width/2 + cos((t+1) * sliceRad) * amplitude,
              y2 = height/2 + sin((t+1) * sliceRad) * amplitude;
        noStroke();
        fill(map(t, 0, super.fft.avgSize()-1, 0, 360), 100, 100);
        triangle(x1, y1, x2, y2, width/2, height/2);
      }
    }
    
    // display the FFT logarithmic averages as a standard equalizer -_-
    stroke(0);
    strokeWeight(2);
    for (int i=0; i<super.fft.avgSize(); i++) {
      // draw a rectangle for each average
      fill(map(i, 0, super.fft.avgSize()-1, 0, 360), 100, 100);
      rect(i*barWidth, height, i*barWidth + barWidth, height - super.fft.getAvg(i));
    }
  }
}
