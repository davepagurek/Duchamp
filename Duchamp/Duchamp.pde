import java.awt.geom.Point2D;
import java.awt.geom.Point2D.Float;
import java.awt.geom.Rectangle2D;
//import java.awt.geom.Rectangle2D.Float;

PImage i1, i2;
Point2D align;

void setup() {
  size(720, 405);
  noLoop();

  i1 = loadImage("img/sample2/03.png");
  i2 = loadImage("img/sample2/04.png");
  align = positionImages(i1, i2);
  //align = new Point2D.Float(0,0);
  println(align);
}

PImage edges(PImage img) {
  PGraphics g = createGraphics(img.width, img.height);
  PImage blurred = createImage(img.width, img.height, RGB);
  blurred.copy(img, 0, 0, img.width, img.height, 0, 0, img.width, img.height);
  blurred.filter(BLUR, 2);
  g.beginDraw();
  g.image(img, 0, 0);
  g.blendMode(DIFFERENCE);
  g.image(blurred, 0, 0);
  g.endDraw();
  g.filter(BLUR, 3);
  g.filter(THRESHOLD, 0.04);
  g.endDraw();
  return g.get();
}

PImage posterize(PImage img) {
  PGraphics g = createGraphics(img.width, img.height);
  g.beginDraw();
  g.image(img, 0, 0);
  g.filter(POSTERIZE, 6);
  g.endDraw();
  return g.get();
}

Point2D positionImages(PImage from, PImage to) {
  PImage a = posterize(from);
  PImage b = posterize(to);
  float minX = 0;
  float minY = 0;
  double minDiff = Double.POSITIVE_INFINITY;
  for (float x = -width*0.2; x < width*0.2; x += 5) {
    for (float y = -height*0.2; y < height*0.2; y += 5) {
      Rectangle2D overlap = new Rectangle2D.Float(min(0,x), min(0,y), width-abs(x), height-abs(y));
      //if ((int)overlap.getWidth() == 0 || (int)overlap.getHeight() == 0) {
        //continue;
      //}
      PGraphics g = createGraphics(width, height);
      //PGraphics g = createGraphics((int)overlap.getWidth(), (int)overlap.getHeight());
      g.beginDraw();
      g.clear();
      g.blendMode(BLEND);
      g.image(a, 0, 0);
      //g.image(a, (int)(0-overlap.getX()), (int)(0-overlap.getY()));
      g.blendMode(DIFFERENCE);
      g.image(b, x, y);
      //g.image(b, (int)(x-overlap.getX()), (int)(y-overlap.getY()));
      g.endDraw();
      double diff = totalColor(g.get());
      if (diff < minDiff) {
        println("" + x + ", " + y + ": " + overlap + "; " + diff);
        minDiff = diff;
        minX = x;
        minY = y;
      }
    }
  }
  return new Point2D.Float(minX, minY);
}

double totalColor(PImage img) {
  img.loadPixels();
  double r = 0, g = 0, b = 0;
  for (int i=0; i<img.pixels.length; i++) {
    color c = img.pixels[i];
    r += c>>16&0xFF;
    g += c>>8&0xFF;
    b += c&0xFF;
  }
  r /= (double)img.pixels.length;
  g /= (double)img.pixels.length;
  b /= (double)img.pixels.length;
  return (r+g+b)/3; // + 20*(1.0 - (double)img.pixels.length / (double)(width*height));
}

void draw() {
  //image(posterize(i1), 0, 0);
  //blendMode(DIFFERENCE);
  //image(posterize(i2), (float)align.getX(), (float)align.getY());
  //blendMode(BLEND);
  //tint(255, 255/3);
  image(posterize(i1), 0, 0);
  tint(255, 255/2);
  image(posterize(i2), (float)align.getX(), (float)align.getY());
}
