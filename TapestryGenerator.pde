import java.util.Collections;

public class TapestryGenerator extends Visulization {
  int blockSize, squareBlocks, bucket;
  float[][] tapestry;
  color from = color(300, 90, 90),
        to = color((hue(from) - 150) % 360 , 90, 90);
  
  public TapestryGenerator() {
    super();
    
    squareBlocks = 35;
    blockSize = width / squareBlocks;
    tapestry = new float[squareBlocks][squareBlocks];
  }
  
  @Override
  public void update() {
    super.fft.forward(player.mix);
    
    // shift forward previous state
    for (int i=0; i < tapestry.length; i++) {
      for (int j=tapestry[i].length - 1; j > 0; j--) {
        tapestry[i][j] = 0.94 * tapestry[i][j-1];  // decay
      }
    }
    
    // load new fft into tapestry
    for (int i=0; i < tapestry.length; i++) {
      bucket = floor(map(i, 0, squareBlocks, 0, 14));
      tapestry[i][0] = -1.5 * super.fft.getAvg(bucket);
    }
    
    background(127);

    if (newColor) {
      from = color(random(0, 360), 90, 90);
      to = color((hue(from) + 120) % 360 , 90, 90);
      newColor = false;
    }

    // 1st person field of view
    PVector eyes = new PVector(
      width/2, 
      -height/2, 
      height/2 / tan(30 * PI / 180.0)
    );
  
    // reference point
    PVector anchor = new PVector(
      width/2, 
      -height, 
      height * 1.5
    );
    
    // set the view static
    camera(
      anchor.x, anchor.y, anchor.z, // reversed from default...
      eyes.x, eyes.y, eyes.z,       // ...3rd person -> 1st person
      0, 1, 0                       // upwards direction is Y
    );
      
      frame.setTitle(floor(frameRate) + " fps");
      stroke(0);
      strokeWeight(2);

    // render quilt
    for (int i=0; i < tapestry.length - 1; i++) {
      for (int j=0; j < tapestry[i].length - 1; j++) {
        drawQuadrant(i, j);
      }
    }
  }
  
  public PVector[] getCorners(int i, int j) {
    return new PVector[] {
      new PVector(i, tapestry[i][j], j),  // upper left
      new PVector(i, tapestry[i][j+1], j+1), // upper right
      new PVector(i+1, tapestry[i+1][j+1], j+1), // lower right
      new PVector(i+1, tapestry[i+1][j], j) // lower left
    };
  }
  
  public void drawQuadrant(int i, int j) {
    PVector[] corners = getCorners(i, j);
    float alpha = (float) (i * squareBlocks + j) / (float) (squareBlocks * squareBlocks);
    
    fill(lerpColor(from, to, alpha));
    beginShape(QUAD);
    for (int k=0; k < corners.length; k++) {
      vertex(
        (corners[k].x + 1) * blockSize,
        corners[k].y,
        (corners[k].z + 1) * blockSize
      );
    }
    endShape(CLOSE);
  }
}
