
public class WaveGenerator extends Visulization {
  private BassDetect bassDetect;
  private ArrayList<Waveform> waves, tombs;
  private int waveAmplitude, circleRadius, timeToLive, timer;
              
  public WaveGenerator() {
    super();
    bassDetect = new BassDetect();
    waves = new ArrayList<Waveform>();
    tombs = new ArrayList<Waveform>();
    
    // params
    waveAmplitude = 30;
    circleRadius = 50;
    timeToLive = 33;
  }
  
  @Override
  public void update() {
    frame.setTitle(floor(frameRate) + " fps // " + waves.size() + " waves");
    background(0);
    
    // update ui
    for (Waveform wf : waves) {
      wf.render();
      // garbage collect the off-screen waves
      if (wf.radiate() <= 0) {
         tombs.add(wf);
      }
    }
    waves.removeAll(tombs);
    tombs.clear();
    
    // every so often... add a new wave
    if ((millis() - timer >= 60) && (waves.size() < 15) && bassDetect.isKick()) {
      // average a few endpoints to close the waveform more naturally
      float[] samples = player.mix.toArray();
      for (int i=1; i<samples.length/256; i++) {
        // rethink this, learn some more math
        samples[i] = ((samples[i] + samples[samples.length-1-i]) / 2) ;
        samples[samples.length-1-i] = ((samples[i] + samples[samples.length-1-i]) / 2);
      }
      
      // spawn
      waves.add(new Waveform(samples, waveAmplitude, circleRadius, timeToLive));
      timer = millis();
    }
  }
}
