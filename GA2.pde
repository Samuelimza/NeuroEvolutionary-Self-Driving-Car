import controlP5.*;
ControlP5 cp5;
int mapWidth, mapHeight;

int noOfCars = 50;
Car[] cars = new Car[noOfCars];
GeneticAlgorithm ga = new GeneticAlgorithm();
ArrayList<Marker> markers;
PImage myMap;
PImage LeftView;

PFont f;
boolean debugMode = true;

void setup() {
  size(1056, 600);
  textAlign(LEFT, TOP);
  //create font object of arial with 25 size
  f = createFont("Arial", 25, true);
  textFont(f);
  rectMode(CENTER);
  noStroke();
  myMap = loadImage("data/Map.png");
  mapWidth = myMap.width;
  mapHeight = myMap.height;
  myMap.loadPixels();
  LeftView = loadImage("data/LeftView.png");
  for (int i = 0; i < cars.length; i++) {
    int species = (i / (noOfCars / 5)) + 1;
    cars[i] = new Car(370, 30, species);
  }
  markers = new ArrayList<Marker>();
  loadMarkers("D:/NewFolder/Osama/Programming/Java/Processing/GA2/data");
  //ga.loadGeneration("74RingaRoses");
  
  cp5 = new ControlP5(this);
  cp5.addTextfield("saveName").setPosition(832,30).setSize(200, 20).setFont(createFont("Arial", 18, true)).setFocus(false).setColor(color(255, 0, 0));
  cp5.addButton("Save").setPosition(892, 70).setSize(100, 40);
  cp5.addTextfield("loadName").setPosition(832,130).setSize(200, 20).setFont(createFont("Arial", 18, true)).setFocus(false).setColor(color(255, 0, 0));
  cp5.addButton("Load").setPosition(892, 170).setSize(100, 40);
}

void draw() {
  background(51);
  //background(myMap);
  //translate(228, 0);
  image(LeftView, 600, 0);//-228, 0);
  image(myMap, 0, 0);
  stroke(4);
  line(828, 0, 828, 600);
  fill(187, 252, 184, 150);
  text("Gen: " + ga.generation, 0, 0);
  for (int i = 1; i < cars.length; i++) {
    cars[i].update();
    cars[i].show();
  }
  cars[0].update();
  cars[0].show();
  //saveFrame("frames/try1/####.tga");
  ga.update();
  if (debugMode) {
    for (int i = 0; i < markers.size(); i++) {
      markers.get(i).show();
    }
  }
}

public void Save(){
  String name = cp5.get(Textfield.class, "saveName").getText();
  ga.saveGeneration(cars, name);
}

public void Load(){
  String name = cp5.get(Textfield.class, "loadName").getText();
  ga.loadGeneration(name);
}


void loadMarkers(String path) {
  JSONArray markersArray = loadJSONArray(path + "/markers1.json");
  for (int i = 0; i < 22; i++) {
    JSONObject mj = markersArray.getJSONObject(i);
    markers.add(new Marker(mj.getInt("x"), mj.getInt("y"), mj.getInt("w"), mj.getInt("h"), mj.getInt("index"), mj.getInt("score")));
  }
}

void keyPressed() {
  if (key == ' ') {
    ga.reproduce();
  }
  if (key == 'd') {
    debugMode = !debugMode;
  }
}
