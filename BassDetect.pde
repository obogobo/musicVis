
public class BassDetect extends Thread { 
  private FFT fftBass;
  private int bassIndex;
  private float noiseFactor;
  private float[] longWindow, shortWindow;
  public float longThreshold, shortThreshold, noiseThreshold;
  
  public BassDetect() {
    // frequency analysis
    fftBass = new FFT(player.bufferSize(), player.sampleRate());
    fftBass.logAverages(22, 1);      // number of "buckets" in the spectra
    longWindow = new float[60*5];    // 60 frames * 5 seconds = 300 sample moving window
    shortWindow = new float[6];      // 1/10th second = 6 sample moving window

    // params
    bassIndex = 1;      // spectra "bucket" considerd to resemble bass
    noiseFactor = 0.1;  // noisiness factor, "just noticeable difference" constant
  }
  
  // continually compute a moving average of the measured bass amplitude, 
  // this can be thought of as the threshold required to register a "kick".
  public void run() {
    while (player.isPlaying()) {      
      // perform a forward FFT on the samples in active's mix buffer
      fftBass.forward(player.mix);
      
      // calculate the bass thresholds
      longThreshold = getAvg(longWindow);
      shortThreshold = getAvg(shortWindow);
      noiseThreshold = ((noiseFactor * longThreshold > noiseFactor * 100) ? (noiseFactor * longThreshold) : (noiseFactor * 100));
      
      // update the bass thresholds
      longWindow[frameCount % longWindow.length] = fftBass.getAvg(bassIndex);
      shortWindow[frameCount % shortWindow.length] = fftBass.getAvg(bassIndex);
      
      try {
        sleep(20);
      } catch (Exception e) {
        e.printStackTrace(); 
      }
    }
  }
  
  // core beat detection logic
  public boolean isKick() {
    boolean isKick = false;
    if ((shortThreshold >= longThreshold) && (shortThreshold > noiseThreshold)) {
      isKick = true;
    }
    return isKick;
  }
  
  public float shortLevel() {
    return shortThreshold;
  }
  
  public float longLevel() {
    return longThreshold;
  }
  
  // draw bass thresholds as horizontal lines
  // very useful when tweaking the beat detection!!
  public void debugDraw() {
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
  
  // helper method for normalizing the frequency windows
  private float getAvg(float[] vals) {
    int n;
    float sum=0;
    for (n=0; n<vals.length; n++) {
      sum += vals[n];
    }
    return sum/n; 
  }
}
