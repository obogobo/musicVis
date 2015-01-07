
public class TerrainGenerator extends Visulization {
  int blockSize, squareBlocks;
  int [] centerPoint;
  float maxDistance, maxHeight;
  float[][] terrain, distance;
  
  public TerrainGenerator() {
    super();
    
    // num blocks (n x n), block dimensions, and center block of grid ("keystone")
    squareBlocks = 31;
    blockSize = width / squareBlocks;
    centerPoint = new int[] { squareBlocks / 2, squareBlocks / 2 };
    maxHeight = 30;
    
    // terrain -> block height mapping == fft response, taken from...
    // distance -> fft avg band ("bucket") == (int) distance from keystone
    terrain = new float[squareBlocks][squareBlocks];
    distance = new float[squareBlocks][squareBlocks];
    
    // init: calculate block distances from keystone
    for (int i=0; i<distance.length; i++) {
      for (int j=0; j<distance[i].length; j++) {
        // distance[i][j] = Math.abs(centerPoint[0] - i) + Math.abs(centerPoint[1] - j);
        distance[i][j] = (float) Math.sqrt(Math.pow(centerPoint[0] - i, 2) + Math.pow(centerPoint[1] - j, 2));
        maxDistance = Math.max(maxDistance, distance[i][j]);
      }
    }
  }
  
  @Override
  public void update() {
    super.fft.forward(player.mix);
    
    // load fft into blocks
    for (int i=0; i<terrain.length; i++) {
      for (int j=0; j<terrain[i].length; j++) {
        int bucket = (int) map(distance[i][j], 0, maxDistance, 0, super.fft.avgSize() - 1);
        terrain[i][j] = Math.min(maxHeight, map(super.fft.getAvg(bucket), 0, 150, 0, 30));
      }
    }
    
    background(127);

    // 1st person field of view
    PVector eyes = new PVector(
      width/2 + map(mouseX, 0, width, -2*width, 2*width), 
      height/2 + map(mouseY, 0, height, -2*height, 2*height), 
      height/2 / tan(30*PI / 180.0)
    );
  
    // reference point
    PVector anchor = new PVector(
      width/2, 
      -height, 
      1000
    );
    
    // set the view
    camera(
      anchor.x, anchor.y, anchor.z, // reversed from default...
      eyes.x, eyes.y, eyes.z,       // ...3rd person -> 1st person
      0, 1, 0                       // upwards direction is Y
    );
      
      frame.setTitle("mouse @ (" + eyes.x + ", " + eyes.y + ") " + floor(frameRate) + " fps");

    // render blocks
    for (int i=0; i<terrain.length; i++) {
      for (int j=0; j<terrain[i].length; j++) {
        pushMatrix();
        translate((blockSize * (j+1)), -(blockSize * (terrain[i][j] / 2.0)), (blockSize * (i+1)));
        fill(map(distance[i][j], 0, maxDistance, 30, 330), 90, 90);
        box(blockSize, blockSize * terrain[i][j], blockSize);
        popMatrix();
      }
    }
  }
}
