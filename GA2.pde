int noOfCars = 20;
Car[] cars = new Car[noOfCars];
GeneticAlgorithm ga = new GeneticAlgorithm();
ArrayList<Marker> markers;
PImage myMap;

//test Car
Car a = new Car(370, 30);
PFont f;
boolean manual = false;

void setup(){
 size(600, 600);
 textAlign(LEFT, TOP);
 //create font object of arial with 25 size
 f = createFont("Arial", 25, true);
 textFont(f);
 rectMode(CENTER);
 noStroke();
 myMap = loadImage("data/Map.png");
 myMap.loadPixels();
 for(int i = 0; i < cars.length; i++){
   cars[i] = new Car(370, 30);
 }
 markers = new ArrayList<Marker>();
 loadMarkers("D:/NewFolder/Osama/Programming/Java/Processing/GA2/data");
}

void draw(){
 //background(51);
 background(myMap);
 stroke(4);
 fill(187, 252, 184, 150);
 text("X: " + (int)a.pos.x + ", Y: " + (int)a.pos.y, 0, 0);
 for(int i = 0; i < cars.length; i++){
   cars[i].update();
   cars[i].show();
 }
 for(int i = 0; i < markers.size(); i++){
   markers.get(i).show();
 }
 a.update();
 a.show();
}

  
void loadMarkers(String path){
  JSONArray markersArray = loadJSONArray(path + "/markers1.json");
  for(int i = 0; i < 22; i++){
    JSONObject mj = markersArray.getJSONObject(i);
    markers.add(new Marker(mj.getInt("x"), mj.getInt("y"), mj.getInt("w"), mj.getInt("h"), mj.getInt("index"), mj.getInt("score")));
  }
}

void keyPressed(){
  if(key == 'm'){
    ga.saveGeneration(cars);
    manual = !manual;
    if(manual){
      a.dead = false;
      a.acc = false;
      a.decc = false;
      a.left = false;
      a.right = false;
    }
  }
  if(key == 'w'){
    a.acc = true;
  }else if(key == 's'){
    a.decc = true;
  }
  if(key == 'd'){
    a.left = true;
  }else if(key == 'a'){
    a.right = true;
  }
}

void keyReleased(){
  if(key == 'w'){
    a.acc = false;
  }else if(key == 's'){
    a.decc = false;
  }
  if(key == 'd'){
    a.left = false;
  }
  if(key == 'a'){
    a.right = false;
  }
}
