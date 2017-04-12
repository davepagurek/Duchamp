import java.util.List;
import java.util.ArrayList;

class TimeMerge {
  List<PImage> images;
  List<Offset> offsets;

  public TimeMerge(List<PImage> images) {
    if (images.size() < 1) {
      throw new IllegalArgumentException("At least one image must be supplied!");
    }

    this.images = images;
    offsets = new ArrayList<Offset>();
    for (int i = 0; i < images.size()-1; i++) {
      offsets.add(new Offset(images.get(i), images.get(i+1)));
      //if (i > 0) {
        //offsets.get(i).makeMask(offsets.get(i-1));
      //}
    }
  }

  public Rectangle2D getBounds() {
    Rectangle2D bounds = new Rectangle2D.Double(
      0,
      0,
      images.get(0).width,
      images.get(0).height
    );

    for (Offset o : offsets) {
      bounds = bounds.createUnion(o.getOffsetRect());
    }

    return bounds;
  }

  public PImage getMergedImage() {
    Rectangle2D bounds = getBounds();
    PGraphics g = createGraphics((int)bounds.getWidth(), (int)bounds.getHeight());
    g.beginDraw();
    g.translate(-(float)bounds.getX(), -(float)bounds.getY());

    // draw images, from last to first
    for (Offset o : offsets) {
      g.pushMatrix();
      g.translate((float)o.getTranslation().getX(), (float)o.getTranslation().getY());
    }
    for (int i = offsets.size()-1; i >= 0; i--) {
      Offset o = offsets.get(i);
      g.image(images.get(i+1), 0, 0);
      g.popMatrix();
    }
    g.image(images.get(0), 0, 0);

    // draw important bits from first to last
    g.pushMatrix();
    for (Offset o : offsets) {
      g.translate((float)o.getTranslation().getX(), (float)o.getTranslation().getY());
      g.image(o.getMasked(), 0, 0);
    }
    g.popMatrix();

    g.endDraw();
    return g.get();
  }
}
