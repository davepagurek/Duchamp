import java.util.Arrays;

PImage mergedImage;
void setup() {
  size(720, 405);
  noLoop();

  mergedImage = new TimeMerge(Arrays.asList(
    loadImage("img/sample2/01.png"),
    loadImage("img/sample2/02.png"),
    loadImage("img/sample2/03.png"),
    loadImage("img/sample2/04.png")
  )).getMergedImage();
}

void draw() {
  image(mergedImage, 0, 0);
}

void mousePressed() {
  redraw();
}
