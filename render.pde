
class Renderer {

  PGraphics gfx = null;

  void begin(PGraphics g) {
    gfx = g;
  }

  void end() {
    gfx = null;
  }

  void _drawEdge(float x0, float y0, float w0, float x1, float y1, float w1, int edgeStyle) {

    PGraphics g = gfx;
    if (g == null)
      g = getGraphics();

    float d0 = 1;
    float d1 = -1;

    float xA = x0 + (w0/2);
    float xB = x1 + (w1/2);

    x0 += (w0/2);
    x1 -= (w1/2);

    if (x1 < x0) {
      x0 -= w0;
      x1 += (w1);
      d0 = -1;
      d1 = 1;
    }

    float dX = (x1-x0)*0.5;
    float dY = (y1-y0)*0.5;

    float ddx = sqrt(dX * dX) * 0.5;

    if (edgeStyle == 1) {
      float ctl = 1.6;
      g.bezier(
        x0, y0, 
        x0+(ddx*d0)*ctl, y0, 
        x1+(ddx*d1)*ctl, y1, 
        x1, y1
        );
      return;
    }

    g.line(x0, y0, x0+dX, y0);
    g.line(x1, y1, x1-dX, y1);
    if (dY != 0) {
      g.line(x0+dX, y0, x1-dX, y1);
    }
  }

  void _drawNode(Node n) {

    PGraphics g = gfx;
    if (g == null)
      g = getGraphics();

    g.pushMatrix();
    g.stroke(0);

    Style style = n.style;

    // ports
    g.strokeWeight(0.5 * style.link);
    g.stroke(style.linkColor);
    g.noFill();
    for (Object c : n.children) {
      Node nc = (Node)c;
      
      if (n.parent != null) {
        drawEdge(n.layout.childrenPort.x, n.layout.childrenPort.y, nc.layout.port.x, nc.layout.port.y);
        continue;
      }
      
      Rect n1 = n.layout;
      Rect n2 = nc.layout;
      _drawEdge(n1.x+(n1.width/2), n1.y+(n1.height/2), n1.width * 0, n2.x+(n2.width/2), n2.y+(n2.height/2), n2.width, 1);
    }

    g.strokeWeight(0.5 * style.border);
    Rect r = new Rect((Rect)n.layout);
    g.fill(style.fillColor);
    g.stroke(style.borderColor);
    g.rect(r.x, r.y, r.width, r.height, 4);

    Style gs = globalStyle;

    Rect ew = gs.calculateTextExtents(n.text, style.textSize);
    Rect eh = gs.calculateTextExtents(" ", style.textSize);
    float tx = (eh.height / 2) + (r.width / 2) - (ew.width / 2);
    float ty = (eh.height / 1.6) + (r.height / 2) - (ew.height / 2);

    if (previewOnly) {
      int border = 8;
      g.fill(style.textColor);
      g.noStroke();
      g.rect(r.x + (border*2), r.y + (border*2), r.width - (border*4), r.height - (border*4));
    } else {
      g.textFont(gs.font, style.textSize);
      g.textAlign(style.textAlign);
      g.fill(style.textColor);
      g.text(n.text, r.x + tx, r.y + ty);
    }

    for (Object c : n.children) {
      Node nc = (Node)c;
      _drawNode(nc);
    }

    g.popMatrix();
  }

  void drawEdge(float x, float y, float xx, float yy) {
    PGraphics g = gfx;
    if (g == null)
      g = getGraphics();

    float tx = (xx - x)/2;
    float ty = (yy - y)/2;

    if (y == yy) {
      g.line(x, y, xx, yy);
    } else {
      g.line(x, y, x+tx, y);
      g.line(x+tx, y, xx-tx, yy);
      g.line(xx, yy, xx-tx, yy);
    }
  }

  void draw(Node root) {

    for (Object c : root.edges) {
      Edge e = (Edge)c;

      if (e.from == null || e.to == null) {
        continue;
      }
      
      Rect n1 = e.from.layout;
      Rect n2 = e.to.layout;
      
      PGraphics g = gfx;
      if (g == null)
        g = getGraphics();

      g.strokeWeight(0.5 * root.style.edge);
      g.stroke(root.style.edgeColor);
      g.noFill();
      _drawEdge(n1.x+(n1.width/2), n1.y+(n1.height/2), n1.width, n2.x+(n2.width/2), n2.y+(n2.height/2), n2.width, 1);
    }
    
    _drawNode(root);
  }
  
  void saveImage(Node root, float scale) {
    
    Rect r = root.layout.bounds; 
    int gw = (int)(r.width * scale);
    int gh = (int)(r.height * scale);
    PGraphics g = createGraphics(gw, gh, JAVA2D);
    
    float xx = r.x * scale;
    float yy = r.y * scale;
    float ww = (r.width * scale) - g.width;
    float hh = (r.height * scale) - g.height;
      
    g.beginDraw();
    g.clear();
    g.background(255);
    
    g.translate(-xx, -yy);
    g.scale(scale);
    
    begin(g);
    draw(root);
    end();
    
    g.endDraw();
    g.save(project + ".png");
    
    println("done");
  }
}

Renderer globalRenderer = new Renderer();