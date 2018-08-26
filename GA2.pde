int noOfCars = 20;
Car[] cars = new Car[noOfCars];
GeneticAlgorithm ga = new GeneticAlgorithm();
PImage myMap;

//test Car
Car a = new Car(370, 30);
PFont f;
boolean manual = false;

void setup(){
 size(600, 600);
 textAlign(LEFT, TOP);
 //create font object of arial with 30 size
 f = createFont("Arial", 25, true);
 rectMode(CENTER);
 noStroke();
 myMap = loadImage("Map.png");
 myMap.loadPixels();
 for(int i = 0; i < cars.length; i++){
   cars[i] = new Car(370, 30);
 }
}

void draw(){
 //background(51);
 background(myMap);
 textFont(f);
 stroke(4);
 fill(187, 252, 184, 150);
 text("X: " + (int)a.pos.x + ", Y: " + (int)a.pos.y, 0, 0);
 for(int i = 0; i < cars.length; i++){
   cars[i].update();
   cars[i].show();
 }
 a.update();
 a.show();
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
