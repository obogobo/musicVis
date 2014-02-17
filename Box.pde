public class Box {
  private PVector spot;
  private color hsb;
  private int boxSize;
  private float boxRoll;
  
  public Box(int boxSize) {
    // spawn at random position
    spot = new PVector(random(-500, width + 500),  // horizontal position
                       random(-250, height + 250), // vertical position
                       random(-2500, -1500));      // distance into screen
    hsb = color(180, 90, 90);
    this.boxSize = boxSize;
  }

  public void render(PVector step) {
    stroke(hsb);
    strokeWeight(1);
    
    // transform each cube individually    
    spot.add(step);
    pushMatrix();
    translate(spot.x, spot.y, spot.z);
    if (false) {
      boxRoll = ((boxRoll + 0.1) % 360);
      rotateY(radians(boxRoll));
      rotateZ(radians(boxRoll));
    }
    fill(0);
    box(boxSize);
    popMatrix();
  }
}
