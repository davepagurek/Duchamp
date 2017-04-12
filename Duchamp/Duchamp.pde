PImage mergedImage;
void setup() {
  size(720, 405);
  //surface.setResizable(true);
  noLoop();

  List<PImage> frames = new ArrayList<PImage>();
  for (int i = 1; i <= 4; i++) {
    frames.add(loadImage(String.format("img/sample2/%02d.png", i)));
  }
  mergedImage = new TimeMerge(frames).getMergedImage();
  surface.setSize(mergedImage.width, mergedImage.height);
}

void draw() {
  background(#000000);
  //translate((width-mergedImage.width)/2, (height-mergedImage.height)/2);
  image(mergedImage, 0, 0);
}

void mousePressed() {
  redraw();
}
