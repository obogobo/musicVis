
public abstract class Visulization {
  protected FFT fft;
  
  public Visulization() {
    this.fft = new FFT(player.bufferSize(), player.sampleRate());
    fft.logAverages(22, 2);
  }
  
  public void update() {
    println("@Override this method!");
  }
}
