String project = "civpro";

Node root;

int defaultBx = 10;
int defaultBy = 10;
int xOffset = 0;
int yOffset = 0;
int bx = defaultBx;
int by = defaultBy;
float scale = 1.4;
float windowScale = 1.0;

float fileScale = 2.0;

boolean locked = false;

int redrawCount = 0;
void doRedraw() {
  redrawCount = 20;
  loop();
}

void settings()
{
  size((int)(1280*windowScale), (int)(720*windowScale));
}

void setup() {
  frameRate(32);
  
  root = new Node();
  
  execCommand("python " + dataPath("../parsey.py") + " " + dataPath(project) + ".yaml");
  root.load(dataPath(project + ".json"));
 
  Layout l = new Layout();
  l.layoutBiTree(root);
  
  centerNode(root.layout);
  doRedraw();
}

void draw() {
  
  background(255);
  pushMatrix();
  
  translate(bx, by);
  scale(scale);
  
  globalRenderer.begin(getGraphics());
  globalRenderer.draw(root);
  globalRenderer.end();
  
  popMatrix();

  if (redrawCount > 0) {
    redrawCount--;
    noStroke();
    fill(0, 255, 0);
    rect(10, 10, 5, 5);
  } else {
    noLoop();
  }
}

void mousePressed() {
  locked = true;

  xOffset = mouseX-bx; 
  yOffset = mouseY-by;

  doRedraw();
}

void mouseDragged() {
  if (locked) {
    bx = mouseX-xOffset; 
    by = mouseY-yOffset;
  }

  doRedraw();
}

void mouseReleased() {
  locked = false;
  doRedraw();
}

void centerNode(Rect n) {
  if (n == null)
    return;
  float fbx = (width/2) - ((n.x + (n.width/2))* scale);
  float fby = (height/2) - ((n.y + (n.height/2))* scale);
  bx = (int)fbx;
  by = (int)fby;
}

void keyReleased() {
  
  // scale
  {
    if (key == '-') {
      scale -= 0.2;
    }
    if (key == '=') {
      scale += 0.2;
    }
    if (scale < 0.4)
      scale = 0.4;
     if (scale > 2.0)
       scale = 2.0;
     
     centerNode(root.layout);
  }
  
  {
    if (key == 'i') {
      println("saving image");
      globalRenderer.saveImage(root, fileScale);
    }
  }
  
  
  if (key == ESC)
    key = 0;

  doRedraw();
}

void execCommand(String cmd) {

    try {
      println("run " + cmd);
      Process p = Runtime.getRuntime().exec(cmd);
      try {
        p.waitFor();
      } 
      catch(Exception e) {
        println("error running command " + cmd);
      }
      println("done");
    }
    catch(java.io.IOException e) {
      println(e);
    }
  }