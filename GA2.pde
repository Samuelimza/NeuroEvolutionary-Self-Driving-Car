import java.text.MessageFormat;
import controlP5.ControlP5;
import controlP5.Textfield;
import controlP5.Button;

private ControlP5 cp5;
private MessageFormat genCounterFormatter;
public int mapWidth, mapHeight;

public int track = 1;
public String mapPath;
private final String leftViewPath = "data/LeftView.png",
markersPath = "data/markers1.json";

//Starting positions for diffenret tracks
public int[] startX = {370, 370};
public int[] startY = {30, 70};

public int noOfCars = 50;
public Car[] cars = new Car[noOfCars];
public Car testingCar;
public GeneticAlgorithm ga = new GeneticAlgorithm();
public ArrayList<Marker> markers;
public PImage myMap;
private PImage LeftView;

private PFont font;
public boolean debugMode = true;
public boolean testing = false;

public void setup() {
  size(1056, 600);
  textAlign(LEFT, TOP);
  //create font object of arial with 25 size
  font = createFont("Arial", 25, true);
  textFont(font);
  rectMode(CENTER);
  noStroke();
  genCounterFormatter = new MessageFormat("Gen: {0}");
  mapPath = new MessageFormat("data/tracks/track{0}.png").format(new Object[] {track});
  myMap = loadImage(mapPath);
  mapWidth = myMap.width;
  mapHeight = myMap.height;
  myMap.loadPixels();
  LeftView = loadImage(leftViewPath);
  for (int i = 0; i < cars.length; i++) {
    int species = (i / (noOfCars / 5)) + 1;
    cars[i] = new Car(370, 30, species);
    if (track == 3) {
      cars[i].pos.y = startY[1];
    }
  }
  
  markers = new ArrayList<Marker>();
  loadMarkers();
  //ga.loadGeneration("74RingaRoses");

  cp5 = new ControlP5(this);
  cp5.addTextfield("saveName").setPosition(832, 30).setSize(200, 20).setFont(createFont("Arial", 18, true)).setFocus(false).setColor(color(255, 0, 0));
  cp5.addButton("Save").setPosition(892, 70).setSize(100, 40);
  cp5.addTextfield("loadName").setPosition(832, 130).setSize(200, 20).setFont(createFont("Arial", 18, true)).setFocus(false).setColor(color(255, 0, 0));
  cp5.addButton("Load").setPosition(837, 170).setSize(100, 40);
  cp5.addButton("LoadBest").setPosition(947, 170).setSize(100, 40);
  //cp5.setAutoDraw(false);
}

public void draw() {
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
    text(genCounterFormatter.format(new Object[] {ga.generation}), 0, 0);
    for (int i = 1; i < cars.length; i++) {
      cars[i].updateCarState();
      cars[i].renderCar();
    }
    cars[0].updateCarState();
    cars[0].renderCar();
    ga.updateGeneticAlgorithmState();
  } else {
    testingCar.updateCarState();
    testingCar.renderCar();
  }

  //if(keyPressed) {
  //  saveFrame("cp5-screenshot.jpg");
  //  println("screenshot saved, includes cp5 controllers.");
  //}

  if (debugMode) {
    for (int i = 0; i < markers.size(); i++) {
      markers.get(i).renderMarker();
    }
  }
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

public void loadMarkers() {
  JSONArray markersArray = loadJSONArray(markersPath);
  for (int i = 0; i < 22; i++) {
    JSONObject mj = markersArray.getJSONObject(i);
    markers.add(new Marker(mj.getInt("x"), mj.getInt("y"), mj.getInt("w"), mj.getInt("h"), mj.getInt("index"), mj.getInt("score")));
  }
}

public void keyPressed() {
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
