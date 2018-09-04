import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class GA2 extends PApplet {


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

public void setup() {
  
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

public void draw() {
  background(51);
  //background(myMap);
  //translate(228, 0);
  image(LeftView, 600, 0);//-228, 0);
  image(myMap, 0, 0);
  stroke(4);
  line(828, 0, 828, 600);
  fill(187, 252, 184, 150);
  text("Gen: " + ga.generation, 0, 0);
  text("Press 'd' to toggle", 842, 300);
  text("debug mode.", 872, 330);
  for (int i = 1; i < cars.length; i++) {
    cars[i].update();
    cars[i].show();
  }
  cars[0].update();
  cars[0].show();
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


public void loadMarkers(String path) {
  JSONArray markersArray = loadJSONArray(path + "/markers1.json");
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
}
class Car {
  //physics attributes
  boolean dead = false;
  boolean acc = false, left = false, right = false, decc = false;
  PVector pos;
  PVector vel;
  float drag = 0.96f;
  float angle = PI;
  float angularVelocity = 0;
  float angularDrag = 0.9f;
  float power = 0.10f;
  float turnSpeed = 0.01f;
  float braking = 0.95f;

  //Neural attributes
  NNetwork neuralNetwork;
  float[][] proximity;

  //Genetic attributes
  int species;
  boolean isBest = false;
  float fitness = 0;
  float mutationRate = 0.01f;
  int previousMarkerIndex = -1;

  Car(int x, int y, int species) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    this.species = species;
    proximity = new float[3][1];
    neuralNetwork = new NNetwork();
    if (species == 1) {
      // 1%
      mutationRate = 0.01f;
    } else if (species == 2) {
      // 3%
      mutationRate = 0.03f;
    } else if (species == 3) {
      // 8%
      mutationRate = 0.08f;
    } else if (species == 4) {
      // 20%
      mutationRate = 0.20f;
    } else if (species == 5) {
      // 100%
      mutationRate = 1.0f;
    }
  }

  public void update() {
    if (!dead) {
      updateMarkerStatus();
      drawSensors();
      setControls();
      if (acc) {
        PVector delta = PVector.fromAngle(angle);
        delta.mult(power);
        vel.add(delta);
      } else if (decc) {
        vel.mult(braking);
      }
      if (left) {
        angularVelocity += turnSpeed;
      }
      if (right) {
        angularVelocity -= turnSpeed;
      }
      pos.add(vel);
      vel.mult(drag);
      angle += angularVelocity;
      angularVelocity *= angularDrag;
      //if controlled by neural network and colliding with walls then die
      if (notOnTrack()) {
        dead = true;
      }
    }
  }

  public void updateMarkerStatus() {
    for (int i = 0; i < markers.size(); i++) {
      Marker current = markers.get(i);
      if (current.colliding(this) && current.index != previousMarkerIndex) {
        if (current.index == previousMarkerIndex + 1) {
          fitness = current.score * current.score;
          ga.activity++;
          if (fitness > 1000) {
            ga.timeoutLimit = 20;
          }
          if (fitness > 4000) {
            ga.timeoutLimit = 30;
          }
          previousMarkerIndex = current.index;
        } else {
          if (previousMarkerIndex == 21 && current.index == 0) {
            fitness = 1000000;
            ga.activity++;
          }
          dead = true;
          println("DIED " + species);
        }
        return;
      }
    }
  }

  //check for points near the periphery of the car that lie in the wall for collision detection
  public boolean notOnTrack() {
    int index0 = (int)pos.x + 7 + (int)pos.y * mapWidth;
    int index1 = (int)pos.x - 7 + (int)pos.y * mapWidth;
    int index2 = (int)pos.x + (int)(pos.y + 7) * mapWidth;
    int index3 = (int)pos.x + (int)(pos.y - 7) * mapWidth;
    boolean condition0 = index0 < 0 || index1 < 0 || index2 < 0 || index3 < 0;
    boolean condition1 = index0 >= myMap.pixels.length || index1 >= myMap.pixels.length || index2 >= myMap.pixels.length || index3 >= myMap.pixels.length;
    if (!condition0 && !condition1) {
      if (myMap.pixels[index0] == -16777216 || myMap.pixels[index1] == -16777216 || myMap.pixels[index2] == -16777216 || myMap.pixels[index3] == -16777216) {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  //setControls sets the inputs to car based on the neural networks output in the not manual mode
  public void setControls() {
    float[][] directions = neuralNetwork.feedForward(proximity);
    //println(directions[0][0] + "," + directions[1][0] + "," + directions[2][0] + "," + directions[3][0]);
    if (directions[0][0] >= 0.5f) {
      acc = true;
    } else {
      acc = false;
    }
    if (directions[1][0] >= 0.5f) {
      right = true;
    } else {
      right = false;
    }
    if (directions[2][0] >= 0.5f) {
      decc = true;
    } else {
      decc = false;
    }
    if (directions[3][0] >= 0.5f) {
      left = true;
    } else {
      left = false;
    }
  }

  //findDistance iterates over unit distances in the heading passed to it until it finds a wall or reaches the sensor end.
  public void findDistance(PVector heading, int index) {
    PVector posCopy = this.pos.copy();
    heading.setMag(1);
    for (int i = 0; i < 100; i++) {
      //updating the posCopy vector to point a unit further in the heading direction passed 
      posCopy.add(heading);
      //checking if the head of the posCopy vector lies in a wall
      if (myMap.pixels[(int)posCopy.x + ((int)posCopy.y) * mapWidth] == -16777216) {
        if (debugMode) {
          fill(255, 0, 0);
          ellipse(posCopy.x, posCopy.y, 5, 5);
        }
        //setting the proximity value to the iteration number aka distance in the heading direction
        proximity[index][0] = i / 100.0f;
        return;
      }
    }
    proximity[index][0] = 1.0f;
  }

  //drawSensors uses cars angle heading to draw proximity sensors and pass arguments to the proximity findDistance function.
  public void drawSensors() {
    PVector heading = PVector.fromAngle(angle - PI / 6);
    heading.mult(100);
    stroke(200, 100, 60);
    //drawing for the -30 degree sensor
    if (debugMode) {
      line(pos.x, pos.y, pos.x + heading.x, pos.y + heading.y);
    }
    findDistance(heading.copy(), 0);
    //drawing for the +30 degree sensor
    heading.rotate(PI / 3);
    if (debugMode) {
      line(pos.x, pos.y, pos.x + heading.x, pos.y + heading.y);
    }
    findDistance(heading.copy(), 2);
    //drawing for the 0 degree sensor
    heading.rotate(-PI / 6);
    if (debugMode) {
      line(pos.x, pos.y, pos.x + heading.x, pos.y + heading.y);
    }
    findDistance(heading.copy(), 1);
    //println(proximity[0][0] + ", " + proximity[1][0] + ", " + proximity[2][0]);
  }

  public void show() {
    if (!(!debugMode && dead)) {
      stroke(0);
      pushMatrix();
      if (species == 1) {
        // 1%
        fill(255, 255, 0, 150);
      } else if (species == 2) {
        // 3%
        fill(0, 0, 130, 150);
      } else if (species == 3) {
        // 8%
        fill(0, 255, 255, 150);
      } else if (species == 4) {
        // 20%
        fill(0, 0, 255, 150);
      } else if (species == 5) {
        // 100%
        fill(255, 0, 0, 150);
      }
      if (isBest) {
        //println("Best Reporting " + previousMarkerIndex);
        fill(0, 255, 0, 150);
      }
      translate(pos.x, pos.y);
      rotate(angle);
      rect(0, 0, 20, 10);
      popMatrix();
    }
  }
}
class GeneticAlgorithm {
  float totalFitness;
  float maxFitness = -1;
  int maxFitI = -1;
  int generation = 0;

  int counter = 0;
  int activity = 0;
  int lastActivity = 0;
  int lastActivitySecond = second();
  int previousSecond = -1;
  int timeoutLimit = 8;

  float[] lastTenMaxFitnesses = new float[10];

  public void update() {
    int second = second();
    if (second != previousSecond) {
      counter++;
      previousSecond = second;
    }
    if (activity != lastActivity) {
      lastActivity = activity;
      lastActivitySecond = second;
    }
    if (counter >= timeoutLimit) {
      reproduce();
      counter = 0;
      println("Reproduced Due to timeout");
    } else if (allDead(cars)) {
      reproduce();
      counter = 0;
      println("Reproduced Due to allDead");
    } else if (lastActivitySecond < second - 3) {
      reproduce();
      counter = 0;
      println("Reproduced due to No Activity");
    }
  }

  public void reproduce() {
    maxFitness = 0;
    for (int i = 0; i < cars.length; i++) {
      if (cars[i].fitness > maxFitness) {
        maxFitness = cars[i].fitness;
        maxFitI = i;
      }
    }
    if (generation < 10) {
      lastTenMaxFitnesses[generation] = maxFitness;
    }
    println("MaxFitness: " + maxFitness);
    Car[] nextGenCars = new Car[noOfCars];
    if (maxFitI != -1) {
      nextGenCars[0] = new Car(370, 30, 1);
      nextGenCars[0].neuralNetwork = new NNetwork(cars[maxFitI].neuralNetwork);
      nextGenCars[0].isBest = true;
    } else {
      int species = (((0 / (noOfCars / 5)) + 1) > 5) ? 5 : ((0 / (noOfCars / 5)) + 1);
      nextGenCars[0] = new Car(370, 30, species);
      nextGenCars[0].neuralNetwork = new NNetwork(chooseParent().neuralNetwork);
      mutate(nextGenCars[0]);
    }
    for (int i = 1; i < cars.length; i++) {
      int species = (((i / (noOfCars / 5)) + 1) > 5) ? 5 : ((i / (noOfCars / 5)) + 1);
      ;
      nextGenCars[i] = new Car(370, 30, species);
      nextGenCars[i].neuralNetwork = new NNetwork(chooseParent().neuralNetwork);
      mutate(nextGenCars[i]);
    }
    cars = nextGenCars;
    generation++;
    lastActivity = second();
  }

  public Car chooseParent() {
    float luckyNumber = random(totalFitness);
    float runningSum = 0;
    for (int i = 0; i < cars.length; i++) {
      runningSum += cars[i].fitness;
      if (runningSum >= luckyNumber) {
        return cars[i];
      }
    }
    return new Car(370, 30, 1);
  }

  public int mutate(Car car) {
    int counter = 0;
    for (int i = 0; i < car.neuralNetwork.weights.length; i++) {
      for (int j = 0; j < car.neuralNetwork.weights[i].length; j++) {
        for (int k = 0; k < car.neuralNetwork.weights[i][j].length; k++) {
          if (random(1) < car.mutationRate) {
            if (random(1) >= 0.5f) {
              car.neuralNetwork.weights[i][j][k] += 0.1f * car.mutationRate * 100;
              counter++;
              //constrain(car.neuralNetwork.weights[i][j][k], -1, 1);
            } else {
              car.neuralNetwork.weights[i][j][k] -= 0.1f * car.mutationRate * 100;
              counter++;
              //constrain(car.neuralNetwork.weights[i][j][k], -1, 1);
            }
          }
        }
      }
    }
    //println("Weights changed: " + counter + ", species: " + car.species);
    return counter;
  }

  public boolean allDead(Car[] cars) {
    for (int i = 0; i < cars.length; i++) {
      if (!cars[i].dead) {
        return false;
      }
    }
    return true;
  }

  public void saveGeneration(Car[] cars, String saveName) {
    JSONArray generationArray = new JSONArray();
    JSONObject metaData = new JSONObject();
    metaData.setInt("Generation", generation);
    metaData.setFloat("drag", cars[0].drag);
    metaData.setFloat("angularDrag", cars[0].angularDrag);
    metaData.setFloat("power", cars[0].power);
    metaData.setFloat("turnSpeed", cars[0].turnSpeed);
    metaData.setFloat("braking", cars[0].braking);
    generationArray.setJSONObject(0, metaData);
    for (int carCounter = 0; carCounter < cars.length; carCounter++) {
      JSONObject carJSON = new JSONObject();
      int weightCounter = 0;
      for (int i = 0; i < cars[carCounter].neuralNetwork.weights.length; i++) {
        for (int j = 0; j < cars[carCounter].neuralNetwork.weights[i].length; j++) {
          for (int k = 0; k < cars[carCounter].neuralNetwork.weights[i][j].length; k++) {
            carJSON.setFloat(str(weightCounter), cars[carCounter].neuralNetwork.weights[i][j][k]);
            weightCounter++;
          }
        }
      }
      carJSON.setBoolean("isBest", cars[carCounter].isBest);
      generationArray.setJSONObject(carCounter + 1, carJSON);
    }
    saveJSONArray(generationArray,"generations/" + saveName + ".json");
  }

  public void loadGeneration(String generationToLoad) {
    JSONArray generationArray = loadJSONArray("generations/" + generationToLoad + ".json");
    JSONObject metaData = generationArray.getJSONObject(0);
    float tempDrag = 0, tempAngularDrag = 0, tempPower = 0, tempTurnSpeed = 0, tempBraking = 0;
    boolean metaDataAvailable = true;
    try {
      generation = metaData.getInt("Generation");
      tempDrag = metaData.getFloat("drag");
      tempAngularDrag = metaData.getFloat("angularDrag");
      tempPower = metaData.getFloat("power");
      tempTurnSpeed = metaData.getFloat("turnSpeed");
      tempBraking = metaData.getFloat("braking");
    }
    catch(Exception exception) {
      metaDataAvailable = false;
    }
    noOfCars = generationArray.size() - 1;
    Car[] loadedCars = new Car[noOfCars];
    for (int carCounter = 0; carCounter < noOfCars; carCounter++) {
      loadedCars[carCounter] = new Car(370, 30, 1);
      if (metaDataAvailable) {
        loadedCars[carCounter].drag = tempDrag;
        loadedCars[carCounter].angularDrag = tempAngularDrag;
        loadedCars[carCounter].turnSpeed = tempTurnSpeed;
        loadedCars[carCounter].power = tempPower;
        loadedCars[carCounter].braking = tempBraking;
      }
      JSONObject carBrain = generationArray.getJSONObject(carCounter + 1);
      try {
        loadedCars[carCounter].isBest = carBrain.getBoolean("isBest");
      }
      catch(Exception NullPointerException) {
      }
      int weightCounter = 0;
      for (int i = 0; i < cars[carCounter].neuralNetwork.weights.length; i++) {
        for (int j = 0; j < cars[carCounter].neuralNetwork.weights[i].length; j++) {
          for (int k = 0; k < cars[carCounter].neuralNetwork.weights[i][j].length; k++) {
            loadedCars[carCounter].neuralNetwork.weights[i][j][k] = carBrain.getFloat(str(weightCounter));
            weightCounter++;
          }
        }
      }
    }
    cars = loadedCars;
  }
}
class Marker{
  int score = 0, index;
  int x, y, w, h;
  
  Marker(int x, int y, int w, int h, int index, int score){
    this.index = index;
    this.score = score;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  public boolean colliding(Car car){
    if(car.pos.x > x - w / 2 && car.pos.x < x + w / 2 && car.pos.y > y - h / 2 && car.pos.y < y + h / 2){
      return true;
    }
    return false;
  }

  public void show(){
    rectMode(CENTER);
    stroke(255, 0, 0);
    noFill();
    rect(x, y, w, h);
  }
}
class NNetwork{
  int[] architecture = {3, 5, 4, 4};
  float[][][] weights = new float[3][][];

  NNetwork(){
    weights = new float[3][][];
    for(int i = 0; i < weights.length; i++){
      weights[i] = new float[this.architecture[i + 1]][this.architecture[i]];
    }
    for(int i = 0; i < weights.length; i++){
      for(int j = 0; j < weights[i].length; j++){
        for(int k = 0; k < weights[i][j].length; k++){
          weights[i][j][k] = (float)(Math.random() * 2 - 1);
        }
      }
    }
  }
  
  NNetwork(NNetwork nn){
    weights = new float[3][][];
    for(int i = 0; i < weights.length; i++){
      weights[i] = new float[this.architecture[i + 1]][this.architecture[i]];
    }
    for(int i = 0; i < weights.length; i++){
      for(int j = 0; j < weights[i].length; j++){
        for(int k = 0; k < weights[i][j].length; k++){
          this.weights[i][j][k] = nn.weights[i][j][k];
        }
      }
    }
  }
  
  public float[][] feedForward(float[][] input){
    float[][] l1 = matrixMult(weights[0], input);
    float[][] l2 = matrixMult(weights[1], l1);
    float[][] output = matrixMult(weights[2], l2);
    return output;
  }
  
  public float[][] matrixMult(float[][] a, float[][] b){
    float[][] c = new float[a.length][b[0].length];
    for(int i = 0; i < a.length; i++){
      for(int j = 0; j < b[0].length; j++){
        for(int k = 0; k < a[0].length; k++){
          c[i][j] = c[i][j] + a[i][k] * b[k][j];
        }
      }
    }
    return c;
  }
}
  public void settings() {  size(1056, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "GA2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
