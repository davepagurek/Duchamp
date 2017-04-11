
PImage i1, i2;
Offset o;

void setup() {
  size(720, 405);
  noLoop();

  i1 = loadImage("img/sample2/03.png");
  i2 = loadImage("img/sample2/04.png");
  o = new Offset(i1, i2);
}

void draw() {
  //image(posterize(i1), 0, 0);
  //blendMode(DIFFERENCE);
  //image(posterize(i2), (float)align.getX(), (float)align.getY());
  //blendMode(BLEND);
  //tint(255, 255/3);
  image(i2, 0, 0);
  image(i1, -(float)o.getTranslation().getX(), -(float)o.getTranslation().getY());
  image(o.getMasked(), 0, 0);
  //tint(255, 255/2);
}
