
class LayoutInfo extends Rect {
  Rect bounds = new Rect();

  Position port = new Position();
  Position childrenPort = new Position();

  ArrayList children;
}

class Layout {

  ArrayList all;

  String mode = null;
  
  Rect getBounds() {
    Rect r = new Rect();
    for (Object c : all) {
      Node nc = (Node)c;
      r.addToBound(nc.layout);
    }
    return r;
  }

  int _getNodeDepth(Node n) {
    int d = 1;
    if (n.parent != null) {
      d += _getNodeDepth(n.parent);
    }
    return d;
  }
  
  int _getDepth() {
    int d = 1;
    for (Object c : all) {
      Node nc = (Node)c;
      int dd = _getNodeDepth(nc);
      if (dd > d)
        d = dd;
    }
    return d;
  }
  
  void _reset(Node n) {
    n.layout = new LayoutInfo();
    n.layout.children = new ArrayList();
    all.add(n);

    for (Object c : n.children) {
      Node nc = (Node)c;

      if (n.parent == null && mode != null) {
        if (!nc.direction.equals(mode))
          continue;
      }

      _reset(nc);
      n.layout.children.add(nc);
    }
  }

  void _calculateSize(Node n) {

    Style style = n.style;
    Rect exT = style.calculateTextExtents(n.text, style.textSize);    
    n.layout.width = exT.width;
    n.layout.height = exT.height;

    ArrayList children = n.layout.children;
    for (Object c : children) {
      Node nc = (Node)c;
      _calculateSize(nc);
    }
  }

  void _calculateBounds(Node n) {

    n.layout.bounds.reset();
    n.layout.bounds.addToBound(n.layout);

    ArrayList children = n.layout.children;
    for (Object c : children) {
      Node nc = (Node)c;
      _calculateBounds(nc);
      n.layout.bounds.addToBound(nc.layout.bounds);
    }
  }

  void _position(Node n) {

    boolean centeredVertically = false;

    if (n.parent != null) {
      if (n.parent.parent == null)
        centeredVertically = true;
    }
    
    Style style = n.style;
    Rect exT = style.calculateTextExtents(n.text, style.textSize);
    Rect exS = style.calculateTextExtents(" ", style.textSize);

    float margin = (exS.height * 0.25 * style.margin);
    float spacing = (exS.width * 0.25 * style.spacing);

    n.layout.width = exT.width + margin;
    n.layout.height = exT.height + (exS.height * 0) + margin;

    float xx = n.layout.x + n.layout.width + (spacing * 2);
    float yy = n.layout.y;

    if (n.childrenDirection.equals("down")) {
      xx = n.layout.x + (n.layout.width / 2) + spacing;
      yy = n.layout.y + n.layout.height + (spacing * 2);
    }

    ArrayList children = n.layout.children;
    for (Object c : children) {
      Node nc = (Node)c;
      nc.layout.x = xx;
      nc.layout.y = yy;
      yy += nc.layout.bounds.height + spacing;
      
      if (mode == "left") {
        nc.layout.x = n.layout.x - (nc.layout.width) - (spacing * 2);
        if (n.childrenDirection.equals("down")) {
          nc.layout.x += (n.layout.width / 2);
        }
      }
      
      _position(nc);
    }
    
    if (centeredVertically && ! n.childrenDirection.equals("down") && children.size() > 1) {
       n.layout.y = n.layout.y + (n.layout.bounds.height / 2); 
    }
  }
  
  void _calculatePorts(Node n) {
    
    n.layout.childrenPort.x = n.layout.x + n.layout.width;
    n.layout.childrenPort.y = n.layout.y + (n.layout.height / 2);

    if (mode == "left") {
      n.layout.childrenPort.x = n.layout.x;
    }
    
    if (n.childrenDirection.equals("down")) {
      n.layout.childrenPort.x = n.layout.x + (n.layout.width / 2);
      n.layout.childrenPort.y = n.layout.y + (n.layout.height / 2);
    }

    ArrayList children = n.layout.children;
    for (Object c : children) {
        Node nc = (Node)c;
        _calculatePorts(nc);
        nc.layout.port.x = nc.layout.x;
        nc.layout.port.y = nc.layout.y + (nc.layout.height / 2);
        
        if (mode == "left") {
          nc.layout.port.x = nc.layout.x + nc.layout.width;
        }
        
    }
  }

  void _calculateRootBounds(Node n, Rect b) {
    if (n.parent == null)
      b.reset();
     
     // padd
     Rect r = new Rect(n.layout);
     r.expandRect(10);
     b.addToBound(r);
     
     for (Object c : n.children) {
        Node nc = (Node)c;
        _calculateRootBounds(nc, b);
     }
  }
  
  void layoutBiTree(Node n) {

    //n.childrenDirection = "down";
    
    mode = "right";

    all = new ArrayList();

    _reset(n);
    _calculateSize(n);

    int d = _getDepth();
    for (int i=0; i<d; i++) {
      _calculateBounds(n);
      _position(n);
    }

    _calculatePorts(n);

    mode = "left";

    all.clear();
    
    _reset(n);
    _calculateSize(n);

    d = _getDepth();
    for (int i=0; i<d; i++) {
      _calculateBounds(n);
      _position(n);
    }
    
    _calculateRootBounds(n, n.layout.bounds);
    
    n.layout.y = n.layout.bounds.height/2;
    
    _calculatePorts(n);
    
    // be neutral
    n.layout.childrenPort.x = n.layout.x + (n.layout.width/2);
    n.layout.childrenPort.y = n.layout.y + (n.layout.height/2);
    
    
  }
  
  void layoutTree(Node n) {

    mode = null;

    all = new ArrayList();

    _reset(n);
    _calculateSize(n);

    int d = 1; // _getDepth();
    for (int i=0; i<d; i++) {
      _calculateBounds(n);
      _position(n);
    }

    _calculatePorts(n);
    _calculateRootBounds(n, n.layout.bounds);
  }
}