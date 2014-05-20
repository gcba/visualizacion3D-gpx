/*
To Do
 
*/


import tomc.gpx.*; //to parse GPX file
import peasy.*; //for mouse pan and zoom controls

//GLOBAL VARIABLES
PeasyCam cam; // PeasyCam object
PFont instructions; //text

//screen limits in lat, lon and elevation
float west = -79.43;
float east = -79.35;
float north = 43.679;
float south = 43.635;
float lowest = 50;
float highest = 200;

//screen display point coordinates
float screen_X;
float screen_Y;
float screen_Z;

//to draw lines in chronological order
int totalCount  = 0;
int toDrawCount = 0;

GPX gpx; // declare a GPX object

//window size
int w=1280;
int h=720;

//framRate
int fps=60;

//draw velocity
int drawVelocity=10;

//max elevation value
int maxElevation=50;

int xRot=0;

//rec
boolean recording=true;

void setup() {
  size(w, h, P3D);
  background(0);
  colorMode(HSB, 360, 100, 100);
  fill(180); //colour of title & instructions
  smooth();

  //initialize font for text
  instructions = loadFont("Serif-24.vlw");

  //initial peasycam settings
  cam = new PeasyCam(this, width/2, height/2, 0, width*0.6);
  cam.lookAt(width/2, height/2, 0);

  gpx = new GPX(this); //initialise the GPX object
  gpx.parse("combinedGPXdata.gpx"); // parse gpx data from the sketch data folder

  //total track point count - used to make animation loop after last point is drawn
  for (int i = 0; i < gpx.getTrackCount(); i++) {
    GPXTrack trk = gpx.getTrack(i);
    for (int j = 0; j < trk.size(); j++) {
      GPXTrackSeg trkseg = trk.getTrackSeg(j);
      for (int k = 0; k < trkseg.size(); k++) {
        totalCount++;
      }
    }
  }
  //println(totalCount);
} // end of setup

void draw() {
  frameRate(fps);
  noCursor();

  background(0);
  noStroke();

  int count = 0;
  boolean finished = false;


  pushMatrix();

  //get the X, Y and Z coordinates of point
  for (int i = 0; i < gpx.getTrackCount(); i++) {
    GPXTrack trk = gpx.getTrack(i);
    for (int j = 0; j < trk.size(); j++) {
      GPXTrackSeg trkseg = trk.getTrackSeg(j);
      for (int k = 0; k < trkseg.size(); k++) {
        GPXPoint pt = trkseg.getPoint(k);
        double ptEle = pt.ele;

        // map lat and long to height & width of screen display
        float screen_X = map((float)pt.lon, west, east, 0, width);
        float screen_Y = map((float)pt.lat, north, south, 0, height);

        //map elevation to appropriate vertical scale for z-axis
        float screen_Z = map((float)ptEle, lowest, highest, 0, 50);

        // call function to display the points
        drawPoints(screen_X, screen_Y, screen_Z, count > toDrawCount - 10);
        //drawSpheres(screen_X, screen_Y, screen_Z );
        count ++;

        if (count > toDrawCount) {  
          finished = true;
          break;
        }
      }
      if (finished) { 
        break;
      }
    }
    if (finished) { 
      break;
    }
  }
  popMatrix();
  //controls speed that the points are drawn
  toDrawCount += drawVelocity;

  //creates continuous loop
  if (count >= totalCount) {
    recording=false;
    toDrawCount = 0;
    exit();
  }
  
  if (recording) {
    saveFrame("output/frame_###.png");
  }

  // display title & instructions
  //instructions();
}


void keyPressed() {

  // If we press r, start or stop recording!
  if (key == 'r' || key == 'R') {
    recording = !recording;
  }
}

