import java.util.List;
import java.util.ArrayList;
import megamu.mesh.*;

class TimeMerge {
  List<PImage> images;
  List<Offset> offsets;

  public TimeMerge(List<PImage> images, int precision) {
    if (images.size() < 1) {
      throw new IllegalArgumentException("At least one image must be supplied!");
    }

    this.images = images;
    offsets = new ArrayList<Offset>();
    for (int i = 0; i < images.size()-1; i++) {
      offsets.add(new Offset(images.get(i), images.get(i+1), precision));
      if (i > 0) {
        offsets.get(i).makeMask(offsets.get(i-1).getDifference());
      }
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
      bounds = bounds.createIntersection(o.getOffsetRect());
    }

    return bounds;
  }
  
  public PImage getInterestingParts(PImage merged) {
    PGraphics g = createGraphics(merged.width, merged.height);
    g.beginDraw();
    g.background(#000000);
    g.blendMode(ADD);
    g.pushMatrix();
    for (Offset o : offsets) {
      g.translate((float)o.getTranslation().getX(), (float)o.getTranslation().getY());
      g.image(o.getMask(), 0, 0);
    }
    g.popMatrix();
    g.tint(255, 255*0.4);
    g.image(edges(merged, 1, 0.04), 0, 0);
    g.endDraw();
    return g.get();
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
  
  public PImage getTesselatedImage() {
    PImage merged = getMergedImage();
    PImage interesting = getInterestingParts(merged);
    PGraphics g = createGraphics(merged.width, merged.height);
    int numPoints = 1500;
    float[][] points = new float[numPoints][2];
    for (int i = 0; i < numPoints; i++) {
      do {
        points[i][0] = random(0, merged.width);
        points[i][1] = random(0, merged.height);
      } while (
        random(0, brightness(interesting.get((int)points[i][0], (int)points[i][1])))
          < 255*0.3
      );
    }
    Voronoi v = new Voronoi(points);
    g.beginDraw();
    g.image(merged, 0, 0);
    g.noStroke();
    MPolygon[] regions = v.getRegions();
    for (int i = 0; i < numPoints; i++) {
      float[][] coords = regions[i].getCoords();
      for (int n = 0; n < coords.length-1; n++) {
        float avgX = 0;
        float avgY = 0;

        avgX += coords[n][0];
        avgX += coords[n+1][0];
        avgX += points[i][0];
        avgX /= 3;

        avgY += coords[n][1];
        avgY += coords[n+1][1];
        avgY += points[i][1];
        avgY /= 3;

        g.fill(
          merged.get(
            (int)max(min(avgX,merged.width-1),0),
            (int)max(min(avgY,merged.height-1),0)
          ),
          255*0.4
        );
        g.beginShape();
        g.vertex(coords[n][0], coords[n][1]);
        g.vertex(coords[n+1][0], coords[n+1][1]);
        g.vertex(points[i][0], points[i][1]);
        g.endShape(CLOSE);
      }
    }

    // draw important bits on top again
    g.tint(255, 255*0.9);
    g.pushMatrix();
    for (Offset o : offsets) {
      g.translate((float)o.getTranslation().getX(), (float)o.getTranslation().getY());
      g.image(o.getMasked(), 0, 0);
    }
    g.popMatrix();
    g.endDraw();
    //return interesting;
    return g.get();
  }
}
