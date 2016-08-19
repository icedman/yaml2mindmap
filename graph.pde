import java.util.Collections;
import java.util.Iterator;

class Edge {
  Node from;
  Node to;
}

class Node {
  String name;
  String direction;
  String childrenDirection;
  String text;
  
  LayoutInfo layout = new LayoutInfo();
  Style style = new Style();
  
  Node parent = null;
  Boolean framed;
  
  ArrayList children = new ArrayList();
  ArrayList edges;

  Node getChildByName(String name) {
    
    if (this.name != null && this.name.equals(name)) {
      return this;
    }
    for(Object c : children) {
      Node n = ((Node)c).getChildByName(name);
      if (n != null)
        return n;
    }
    return null;
  }
  
  Node _loadNode(Node n, JSONObject json) {

    try { 
      n.name = json.getString("name");
    } 
    catch(Exception e) {
    }
    
    try { 
      n.text = json.getString("text");
    } 
    catch(Exception e) {
    }
    
    try { 
      n.direction = json.getString("direction");
    } 
    catch(Exception e) {
      n.direction = "right";
    }
    
    if (n.text.equals("_style") && n.parent != null) {
      try {
        n.parent.style.loadStyle(json);
      } catch (Exception e) {
      }
    }
    
    if (n.text.indexOf("_") == 0)
      return null;
    
    try { 
      n.childrenDirection = json.getString("childrenDirection");
    } 
    catch(Exception e) {
      n.childrenDirection = "";
    }
    
    try {
      n.framed = json.getString("framed").equals("true") ? true : false;
    }
    catch(Exception e) {
    }
    
    // children
    try {
      JSONArray jnodes = json.getJSONArray("nodes");
      for (int i = 0; i < jnodes.size(); i++) {
        JSONObject jchild = jnodes.getJSONObject(i); 
        Node child = new Node();
        child.parent = n;
        
        if (_loadNode(child, jchild) != null)
          n.children.add(child);
        
      }
    } 
    catch (Exception e) {
    }
    
    return n;
  }
  
  void _dump(Node n) {
    println(n.text);
    for (Object obj : n.children) {
      _dump((Node)obj);
    }
  }

  void load(String fullPath) {

    try {
      JSONObject jobj = loadJSONObject(fullPath);
      _loadNode(this, jobj);
      
      this.edges = new ArrayList();
      
      // load edges
      try {
        JSONArray jedges = jobj.getJSONArray("edges");
        for (int i = 0; i < jedges.size(); i++) {
          JSONObject jchild = jedges.getJSONObject(i);
          String in1 = jchild.getString("n1");
          String in2 = jchild.getString("n2");
          Edge e = new Edge();
          e.from = this.getChildByName(in1);
          e.to = this.getChildByName(in2);
          if (e.from != null || e.to != null) {
             this.edges.add(e);
          }
        }

        println("edges:" + root.edges.size());
      } 
      catch(Exception e) {
      }
      
      //_dump(this);
    } 
    catch (Exception e) {
      println("unable to load " + fullPath);
    }
  }
 
}