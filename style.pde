import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.awt.Color;

class Style {

  public String name;
  public String fontName = "menlo";

  public int margin = 2;
  public int spacing = 2;
  
  public int border = 1;
  public color borderColor = color(0x80);
  public int link = 2;
  public color linkColor = color(0x40);
  public int edge = 1;
  public color edgeColor = color(0xff,0x00,0x00);
  
  public int roundCorner = 8;
  public color textColor = color(0x0); //color(0xff, 0xff, 0xff);
  public color fillColor = color(0xff); //color(0x50, 0x50, 0x50);
  public int textSize = 12;
  int textAlign = LEFT;
  
  PFont font;

  Style() {
  }
  
  Style(String name) {
    this.name = name;
  }

  void _prep() {
    
    if (font == null) {
      font = createFont(fontName, textSize, true);
    }
    
  }

  int _stringLines(String l) {
    String lines[] = l.split("\n");
    return lines.length;
  }

  float _stringMaxWidth(String l) {
    String lines[] = l.split("\n");
    float tw = textWidth("  ");
    for (String s : lines) {
      float tt = textWidth(s + "  ");
      if (tt > tw)
        tw = tt;
    }
    return tw;
  }

  Rect calculateTextExtents(String text, int size) {
    
    _prep();
    
    Rect r = new Rect();
    
    textFont(font, size);
    
    r.width = _stringMaxWidth(text) + (this.margin * 2);
    r.height = _stringLines(text) * (this.textSize + 6);
    
    return r;
  }
 
  void loadStyle(JSONObject s) {

    try {
      Field fields[] = Style.class.getFields();
      for(Field f : fields) {
        String sfield = f.toString(); 
        String stype = f.getGenericType().toString();
        String sname = sfield.substring(sfield.lastIndexOf(".")+1);
        if (stype.equals("int")) {
          if (sname.indexOf("color") >= 0 || sname.indexOf("Color") >= 0) {
            try {
              String sv = s.getString(sname);
              String rr = sv.substring(0,2);
              String gg = sv.substring(2,4);
              String bb = sv.substring(4,6);
              color v = color(Integer.parseInt(rr, 16), Integer.parseInt(gg, 16), Integer.parseInt(bb, 16));
              f.set(this, v);
            } catch(Exception e) {
            }
          } else {
            try {
              int v = s.getInt(sname);
              f.set(this, v);
            } catch(Exception e) {
            }
          }
        }
      }
    } catch(Exception e) {
      println(e);
    }
    
    //println(s);
    //for(
  }
}

Style globalStyle = new Style("global");