double avgBrightness(PImage img) {
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
  return (r+g+b)/3;
}

PImage posterize(PImage img) {
  PGraphics g = createGraphics(img.width, img.height);
  g.beginDraw();
  g.image(img, 0, 0);
  g.filter(BLUR, 1);
  g.filter(POSTERIZE, 4);
  g.endDraw();
  return g.get();
}

PImage edges(PImage img, int blur, float threshold) {
  PGraphics g = createGraphics(img.width, img.height);
  PImage blurred = createImage(img.width, img.height, RGB);
  blurred.copy(img, 0, 0, img.width, img.height, 0, 0, img.width, img.height);
  blurred.filter(BLUR, 2);
  g.beginDraw();
  g.image(blurred, 0, 0);
  g.blendMode(SUBTRACT);
  g.image(img, 0, 0);
  g.endDraw();
  g.filter(BLUR, blur);
  g.filter(THRESHOLD, threshold);
  g.endDraw();
  return g.get();
}