import java.awt.geom.Point2D;
import java.awt.geom.Point2D.Float;
import java.awt.geom.Rectangle2D;

class Offset {
  Point2D translation;
  PImage imgMask, imgDifference, from, to, filteredFrom, filteredTo;

  public Offset(PImage from, PImage to) {
    if (from.width != to.width || from.height != to.height) {
      throw new IllegalArgumentException("Images must be the same size!");
    }

    this.from = from;
    this.to = to;
    filteredFrom = posterize(from);
    filteredTo = posterize(to);
    translation = findTranslation();
    imgDifference = findDifference();
    imgMask = imgDifference;
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

  public void makeMask(PImage prevDifference) {
    PGraphics g = createGraphics(to.width, to.height);
    g.beginDraw();
    g.image(imgDifference, 0, 0);
    g.blendMode(SUBTRACT);
    g.image(prevDifference, -(float)translation.getX(), -(float)translation.getY());
    g.filter(THRESHOLD, 0.23);
    g.filter(BLUR, 3);
    g.endDraw();
    imgMask = g.get();
  }

  public PImage getDifference() {
    return imgDifference;
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
    for (float x = -width*0.2; x < width*0.2; x += 5) {
      for (float y = -height*0.2; y < height*0.2; y += 5) {
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

  private PImage findDifference() {
    PImage fromEdges = edges(from);
    PImage toEdges = edges(to);
    PGraphics g = createGraphics(from.width, from.height);
    g.beginDraw();
    g.background(#000000);
    g.clip(
      -(float)getTranslation().getX(),
      -(float)getTranslation().getY(),
      from.width,
      from.height
    );
    g.image(toEdges, 0, 0);
    g.noClip();
    g.blendMode(SUBTRACT);
    g.image(fromEdges, -(float)getTranslation().getX(), -(float)getTranslation().getY());
    g.filter(BLUR, 5);
    g.filter(THRESHOLD, 0.22);
    g.filter(BLUR, 3);
    g.endDraw();
    return g.get();
  }
}
