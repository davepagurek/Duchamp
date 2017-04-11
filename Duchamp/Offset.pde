import java.awt.geom.Point2D;
import java.awt.geom.Point2D.Float;
import java.awt.geom.Rectangle2D;

class Offset {
  Point2D translation;
  PImage mask, from, to;

  public Offset(PImage from, PImage to) {
    this.from = from;
    this.to = to;
    this.translation = findTranslation(from, to);
    this.mask = createImage(from.width, to.height, RGB);
  }

  public Point2D getTranslation() {
    return translation;
  }

  public PImage getMask() {
    return mask;
  }

  private Point2D findTranslation(PImage from, PImage to) {
    PImage a = posterize(from);
    PImage b = posterize(to);
    float minX = 0;
    float minY = 0;
    double minDiff = Double.POSITIVE_INFINITY;
    for (float x = -width*0.2; x < width*0.2; x += 5) {
      for (float y = -height*0.2; y < height*0.2; y += 5) {
        Rectangle2D overlap = new Rectangle2D.Float(min(0,x), min(0,y), width-abs(x), height-abs(y));

        PGraphics g = createGraphics(from.width, from.height);

        g.beginDraw();
        g.clear();
        g.blendMode(BLEND);
        g.image(a, 0, 0);
        g.blendMode(DIFFERENCE);
        g.image(b, x, y);
        g.endDraw();

        double diff = avgBrightness(g.get());

        if (diff < minDiff) {
          minDiff = diff;
          minX = x;
          minY = y;
        }
      }
    }

    return new Point2D.Float(minX, minY);
  }
}
