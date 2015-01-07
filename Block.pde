public class Block {
  private PVector spot;
  private color hsb;
  private float blockSize;
  private float blockRoll;
  
  // questions: is there an easy way to determine if an object is on screen?
  
  public Block(float blockSize) {   
    float r;
    spot = new PVector();
    
    // spawn at random position
    r = random(1);
    spot.x = width/2 + (r > 0.5 ? 1 : -1) * random(blockSize, width/2);
    r = random(1);
    spot.y = height/2 + (r > 0.5 ? 1 : -1) * random(blockSize, height/2);
    spot.z = random(-depth, -blockSize);  // distance into screen
    
    this.hsb = color(180, 100, 100);
    this.blockSize = blockSize;
  }

  public void render(PVector step) {
    stroke(hsb);
    strokeWeight(1);
    
    // transform each cube individually    
    spot.add(step);
    pushMatrix();
    translate(spot.x, spot.y, spot.z);
    if (false) {
      blockRoll = ((blockRoll + 0.1) % 360);
      rotateY(radians(blockRoll));
      rotateZ(radians(blockRoll));
    }
    fill(0);
    box(blockSize);
    popMatrix();
  }
}
