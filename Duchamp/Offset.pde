import java.awt.geom.Point2D;
import java.awt.geom.Point2D.Float;
import java.awt.geom.Rectangle2D;

class Offset {
  Point2D translation;
  PImage imgMask, from, to, filteredFrom, filteredTo;

  public Offset(PImage from, PImage to) {
    if (from.width != to.width || from.height != to.height) {
      throw new IllegalArgumentException("Images must be the same size!");
    }

    this.from = from;
    this.to = to;
    this.filteredFrom = posterize(from);
    this.filteredTo = posterize(to);
    this.translation = findTranslation();
    this.imgMask = findMask();
  }

  public Point2D getTranslation() {
    return translation;
  }

  public Rectangle2D getOffsetRect() {
    return new Rectangle2D.Double(
        translation.getX(),
        translation.getY(),
        from.width,
        from.height
    );
  }

  public PImage getMasked() {
    PImage masked = createImage(to.width, to.height, ARGB);
    masked.copy(to, 0, 0, to.width, to.height, 0, 0, to.width, to.height);
    masked.mask(imgMask);
    return masked;
  }

  private Point2D findTranslation() {
    float minX = 0;
    float minY = 0;
    double minDiff = Double.POSITIVE_INFINITY;
    for (float x = -width*0.2; x < width*0.2; x += 20) {
      for (float y = -height*0.2; y < height*0.2; y += 20) {
        Rectangle2D overlap = new Rectangle2D.Float(min(0,x), min(0,y), width-abs(x), height-abs(y));

        PGraphics g = createGraphics(from.width, from.height);

        g.beginDraw();
        g.clear();
        g.blendMode(BLEND);
        g.image(filteredFrom, 0, 0);
        g.blendMode(DIFFERENCE);
        g.image(filteredTo, x, y);
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

  private PImage findMask() {
    PGraphics g = createGraphics(from.width, from.height);
    g.beginDraw();
    g.background(#000000);
    g.clip(
      -(float)getTranslation().getX(),
      -(float)getTranslation().getY(),
      from.width,
      from.height
    );
    g.image(filteredTo, 0, 0);
    g.noClip();
    g.blendMode(SUBTRACT);
    g.image(filteredFrom, -(float)getTranslation().getX(), -(float)getTranslation().getY());
    g.filter(BLUR, 8);
    g.filter(THRESHOLD, 0.23);
    g.filter(BLUR, 3);
    g.endDraw();
    return g.get();
  }
}
