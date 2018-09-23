import controlP5.ControlP5;
import controlP5.Textfield;
import controlP5.Button;

ControlP5 cp5;
int mapWidth, mapHeight;

int track = 2;

//Starting positioons for diffenret tracks
int[] startX = {370, 370};
int[] startY = {30, 70};

int noOfCars = 50;
Car[] cars = new Car[noOfCars];
Car testingCar;
GeneticAlgorithm ga = new GeneticAlgorithm();
ArrayList<Marker> markers;
PImage myMap;
PImage LeftView;

PFont f;
boolean debugMode = true;
boolean testing = false;

void setup() {
  size(1056, 600);
  textAlign(LEFT, TOP);
  //create font object of arial with 25 size
  f = createFont("Arial", 25, true);
  textFont(f);
  rectMode(CENTER);
  noStroke();
  myMap = loadImage("data/tracks/track" + track + ".png");
  mapWidth = myMap.width;
  mapHeight = myMap.height;
  println(mapWidth + ", " + mapHeight);
  myMap.loadPixels();
  LeftView = loadImage("data/LeftView.png");
  for (int i = 0; i < cars.length; i++) {
    int species = (i / (noOfCars / 5)) + 1;
    cars[i] = new Car(370, 30, species);
    if(track == 3){
      cars[i].pos.y = startY[1];
    }
  }
  markers = new ArrayList<Marker>();
  loadMarkers("D:/NewFolder/Osama/Programming/Java/Processing/GA2/data");
  //ga.loadGeneration("74RingaRoses");

  cp5 = new ControlP5(this);
  cp5.addTextfield("saveName").setPosition(832, 30).setSize(200, 20).setFont(createFont("Arial", 18, true)).setFocus(false).setColor(color(255, 0, 0));
  cp5.addButton("Save").setPosition(892, 70).setSize(100, 40);
  cp5.addTextfield("loadName").setPosition(832, 130).setSize(200, 20).setFont(createFont("Arial", 18, true)).setFocus(false).setColor(color(255, 0, 0));
  cp5.addButton("Load").setPosition(837, 170).setSize(100, 40);
  cp5.addButton("LoadBest").setPosition(947, 170).setSize(100, 40);
  //cp5.setAutoDraw(false);
}

void draw() {
  background(51);
  //background(myMap);
  //translate(228, 0);
  image(LeftView, 600, 0);//-228, 0);
  image(myMap, 0, 0);
  //cp5.draw();
  stroke(4);
  line(828, 0, 828, 600);
  fill(187, 252, 184, 150);
  if (!testing) {
    text("Gen: " + ga.generation, 0, 0);
    for (int i = 1; i < cars.length; i++) {
      cars[i].update();
      cars[i].show();
    }
    cars[0].update();
    cars[0].show();
    ga.update();
  } else {
    testingCar.update();
    testingCar.show();
  }
  
  //if(keyPressed) {
  //  saveFrame("cp5-screenshot.jpg");
  //  println("screenshot saved, includes cp5 controllers.");
  //}
  
  //if (debugMode) {
  //  for (int i = 0; i < markers.size(); i++) {
  //    markers.get(i).show();
  //  }
  //}
}

public void Save() {
  String name = cp5.get(Textfield.class, "saveName").getText();
  ga.saveGeneration(cars, name);
}

public void Load() {
  String name = cp5.get(Textfield.class, "loadName").getText();
  ga.loadGeneration(name);
}

public void LoadBest() {
  String name = cp5.get(Textfield.class, "loadName").getText();
  ga.loadGeneration(name);
  testing = true;
  ga.setTestingCar();
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
  if (key == 't') {
    testing = !testing;
    if (testing) {
      ga.setTestingCar();
    } else {
    }
  }
}
