
public class WaveGenerator extends Visulization {
  private ArrayList<Waveform> waves, tombs;
  private int waveAmplitude, waveRadius, timeToLive, timer;
  private int waveLimit, rateLimit, minWaveSpeed, maxWaveSpeed;
  private float expansionFactor;
              
  public WaveGenerator() {
    super();

    // bookkeeping
    waves = new ArrayList<Waveform>();
    tombs = new ArrayList<Waveform>();
    
    // global params
    minWaveSpeed = 2;
    maxWaveSpeed = 8;
    waveLimit = 10;
    rateLimit = 80;  // down time between waves
    
    // local params
    waveAmplitude = 30;
    waveRadius = 50;
    timeToLive = 45;
  }
  
  @Override
  public void update() {    
    frame.setTitle(floor(frameRate) + " fps // " + waves.size() + " waves");
    
    // update ui
    for (Waveform wf : waves) {
      expansionFactor = (dubMode ? map(bassDetect.shortLevel(), 0, 150, minWaveSpeed, maxWaveSpeed) : maxWaveSpeed);
      wf.render();
      // radiate the waves, garbage collect those that have expired or, are (almost) off-screen
      if (wf.radiate(expansionFactor) <= 0 || wf.radius >= width/2) {
         tombs.add(wf);
      }
    }
    waves.removeAll(tombs);
    tombs.clear();
    
    // every so often... add a new wave
    if ((millis() - timer >= rateLimit) && (waves.size() < waveLimit) && (debugMode || bassDetect.isKick())) {
      // average a few endpoints to close the waveform more naturally
      float[] samples = player.mix.toArray();
        for (int i=0; i<samples.length/256; i++) {
          samples[i] = ((samples[i] + samples[samples.length-1-i]) / 2);
          samples[samples.length-1-i] = ((samples[i] + samples[samples.length-1-i]) / 2);
        }      
      // spawn it!
      waves.add(new Waveform(samples, waveAmplitude, waveRadius, timeToLive));
      timer = millis();
    }
  }
}
