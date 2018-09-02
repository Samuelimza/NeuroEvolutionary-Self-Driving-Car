class Car {
  //physics attributes
  boolean dead = false;
  boolean acc = false, left = false, right = false, decc = false;
  PVector pos;
  PVector vel;
  float drag = 0.96;
  float angle = PI;
  float angularVelocity = 0;
  float angularDrag = 0.9;
  float power = 0.10;
  float turnSpeed = 0.01;
  float braking = 0.95;

  //Neural attributes
  NNetwork neuralNetwork;
  float[][] proximity;

  //Genetic attributes
  int species;
  boolean isBest = false;
  float fitness = 0;
  float mutationRate = 0.01;
  int previousMarkerIndex = -1;

  Car(int x, int y, int species) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    this.species = species;
    proximity = new float[3][1];
    neuralNetwork = new NNetwork();
    if (species == 1) {
      // 1%
      mutationRate = 0.01;
    } else if (species == 2) {
      // 3%
      mutationRate = 0.03;
    } else if (species == 3) {
      // 8%
      mutationRate = 0.08;
    } else if (species == 4) {
      // 20%
      mutationRate = 0.20;
    } else if (species == 5) {
      // 100%
      mutationRate = 1.0;
    }
  }

  void update() {
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

  void updateMarkerStatus() {
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
  boolean notOnTrack() {
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
  void setControls() {
    float[][] directions = neuralNetwork.feedForward(proximity);
    //println(directions[0][0] + "," + directions[1][0] + "," + directions[2][0] + "," + directions[3][0]);
    if (directions[0][0] >= 0.5) {
      acc = true;
    } else {
      acc = false;
    }
    if (directions[1][0] >= 0.5) {
      right = true;
    } else {
      right = false;
    }
    if (directions[2][0] >= 0.5) {
      decc = true;
    } else {
      decc = false;
    }
    if (directions[3][0] >= 0.5) {
      left = true;
    } else {
      left = false;
    }
  }

  //findDistance iterates over unit distances in the heading passed to it until it finds a wall or reaches the sensor end.
  void findDistance(PVector heading, int index) {
    PVector posCopy = this.pos.copy();
    heading.setMag(1);
    for (int i = 0; i < 100; i++) {
      //updating the posCopy vector to point a unit further in the heading direction passed 
      posCopy.add(heading);
      //checking if the head of the posCopy vector lies in a wall
      if (myMap.pixels[(int)posCopy.x + ((int)posCopy.y) * mapWidth] == -16777216) {
        //fill(255, 0, 0);
        //ellipse(posCopy.x, posCopy.y, 5, 5);
        //setting the proximity value to the iteration number aka distance in the heading direction
        proximity[index][0] = i / 100.0;
        return;
      }
    }
    proximity[index][0] = 1.0;
  }

  //drawSensors uses cars angle heading to draw proximity sensors and pass arguments to the proximity findDistance function.
  void drawSensors() {
    PVector heading = PVector.fromAngle(angle - PI / 6);
    heading.mult(100);
    stroke(200, 100, 60);
    //drawing for the -30 degree sensor
    //line(pos.x, pos.y, pos.x + heading.x, pos.y + heading.y);
    findDistance(heading.copy(), 0);
    //drawing for the +30 degree sensor
    heading.rotate(PI / 3);
    //line(pos.x, pos.y, pos.x + heading.x, pos.y + heading.y);
    findDistance(heading.copy(), 2);
    //drawing for the 0 degree sensor
    heading.rotate(-PI / 6);
    //line(pos.x, pos.y, pos.x + heading.x, pos.y + heading.y);
    findDistance(heading.copy(), 1);
    //println(proximity[0][0] + ", " + proximity[1][0] + ", " + proximity[2][0]);
  }

  void show() {
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
