
public class BlockGenerator extends Visulization {
  private BassDetect bassDetect;
  private ArrayList<Box> boxes, tombs;
  private int boxSize;
  private float boxRoll;
  private PVector boxStep;
  
  public BlockGenerator() {
    super();
    bassDetect = new BassDetect();
    
    // params
    boxes = new ArrayList<Box>();
    tombs = new ArrayList<Box>();
    boxStep = new PVector(0,0,2);
    boxSize = 100;
    boxRoll = 0;
  }
  
  @Override
  public void update() {
    frame.setTitle(floor(frameRate) + " fps // " + boxes.size() + " cubes");
    background(61);
    
    if (debug) {
       bassDetect.debugDraw(); 
    }
    
    if (bassDetect.isKick()) {
      boxStep.z = 25;
    }
    
    // add the cubes!
    if (boxes.size() < 40) {
      boxes.add(new Box(boxSize));
    }
    
    // translate and render 'em
    for (Box b : boxes) {
      b.render(boxStep);
      // garbage collect the off-screen cubes
      if (b.spot.x < -500 || b.spot.x > (width + 500)
          || b.spot.y < -500 || b.spot.y > (height + 500)
          || b.spot.z > (boxSize * 2)) {
        tombs.add(b);
      }
    }
    boxes.removeAll(tombs);
    tombs.clear();
    
    // return to baseline (bassline lol) cube speed
    boxStep.z = 2;
  }
}
