
public class BlockGenerator extends Visulization {
  private ArrayList<Block> blocks, tombs;
  private float blockSize;
  private float blockRoll;
  private PVector blockStep;
  
  public BlockGenerator() {
    super();
    
    // bookkeeping
    blocks = new ArrayList<Block>();
    tombs = new ArrayList<Block>();
    
    // params
    blockStep = new PVector(0,0,2);
    blockSize = (width/height) * 50;
    blockRoll = 0;
  }
  
  @Override
  public void update() {
    frame.setTitle(floor(frameRate) + " fps // " + blocks.size() + " cubes");
    
    // bind block speed to bass level (max 75)
    if (cruiseMode) {
      blockStep.z = Math.min(75, (bassDetect.longLevel() + bassDetect.shortLevel()) / 2);
    } else if (dubMode && bassDetect.isKick()) {
      blockStep.z = Math.min(75, bassDetect.longLevel());
    } else if (bassDetect.isKick()){
      blockStep.z = 25;
    } else {
      blockStep.z = 2;
    }
    
    // add the cubes!
    if (blocks.size() < 150) {
      blocks.add(new Block(blockSize));
    }
    
    // translate and render 'em
    for (Block b : blocks) {
      b.render(blockStep);
      // garbage collect the off-screen cubes
      if (b.spot.x < -width/2 || b.spot.x > width*1.5
          || b.spot.y < -height/2 || b.spot.y > height*1.5
          || b.spot.z > depth / tan(PI*30.0 / 180.0)) {
        tombs.add(b);
      }
    }
    blocks.removeAll(tombs);
    tombs.clear();
    
    if (debugMode) {
       bassDetect.debugDraw(); 
    }
  }
}
