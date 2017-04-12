PImage mergedImage;
void setup() {
  size(720, 405);
  noLoop();

  Movie m = new Movie(this, "sample1.mp4");
  List<PImage> f = frames(m, 8, 0.4, 20);
  m.stop();
  mergedImage = new TimeMerge(f, 10).getTesselatedImage();
  surface.setSize(mergedImage.width, mergedImage.height);
}

void draw() {
  image(mergedImage, 0, 0);
}
