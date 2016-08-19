class Position {
  float x;
  float y;
}

class Rect {
  float x = 0;
  float y = 0;
  float width = 0;
  float height = 0;

  Rect() {
  }
  
  Rect(Rect r) {
    setRect(r);
  }
  
  void setRect(Rect r) {
    x = r.x;
    y = r.y;
    width = r.width;
    height = r.height;
  }
  
  void expandRect(int size) {
    x -= size;
    width += (size*2);
    y -= size;
    height += (size*2);
  }

  void addToBound(Rect r) {

    if (x == 0 && y == 0 && width == 0 && height == 0) {
      x = r.x;
      y = r.y;
      width = r.width;
      height = r.height;
      return;
    }

    float x0 = x;
    float y0 = y;
    float x1 = x + width;
    float y1 = y + height;

    if (x0 > r.x)
      x0 = r.x;
    if (y0 > r.y)
      y0 = r.y;
    if (x1 < r.x + r.width)
      x1 = r.x + r.width;
    if (y1 < r.y + r.height)
      y1 = r.y + r.height;

    x = x0;
    y = y0;
    width = x1 - x;
    height = y1 - y;
  }

  void reset() {
    x = 0;
    y = 0;
    width = 0;
    height = 0;
  }
}