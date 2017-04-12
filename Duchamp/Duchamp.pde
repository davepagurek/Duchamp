PImage mergedImage;
void setup() {
  size(720, 405);
  //surface.setResizable(true);
  noLoop();

  List<PImage> frames = new ArrayList<PImage>();
  for (int i = 1; i <= 4; i++) {
    frames.add(loadImage(String.format("img/sample1/%02d.png", i)));
  }
  mergedImage = new TimeMerge(frames, 20).getTesselatedImage();
  surface.setSize(mergedImage.width, mergedImage.height);
}

void draw() {
  image(mergedImage, 0, 0);
}
