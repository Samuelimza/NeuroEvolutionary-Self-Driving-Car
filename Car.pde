public class Car {
  //physics attributes
  public boolean dead = false;
  private boolean accelerating = false, turningLeft = false, turningRight = false, decelerating = false;
  public PVector pos;
  public PVector vel;
  public float drag = 0.96;
  public float angle = PI;
  public float angularVelocity = 0;
  public float angularDrag = 0.9;
  public float power = 0.10;
  public float turnSpeed = 0.01;
  public float braking = 0.95;

  //Neural attributes
  public NNetwork neuralNetwork;
  private float[][] proximity;

  //Genetic attributes
  public int proximitySensorLength = 200;
  private int species;
  public boolean isBest = false;
  public float fitness = 0;
  public float mutationRate = 0.01;
  private int previousMarkerIndex = -1;

  public Car(int x, int y, int species) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    this.species = species;
    proximity = new float[3][1];
    neuralNetwork = new NNetwork();
    switch(species) {
    case 1: // 1%
      mutationRate = 0.01; 
      break;
    case 2:// 3%
      mutationRate = 0.03;
      break;
    case 3:// 8%
      mutationRate = 0.08;
      break;
    case 4:// 20%
      mutationRate = 0.20;
      break;
    case 5:// 100%
      mutationRate = 1.0;
      break;
    }
  }

  public void updateCarState() {
    if (!dead) {
      if (!testing) {
        updateMarkerStatus();
      }
      drawSensors();
      setControls();
      if (accelerating) {
        PVector delta = PVector.fromAngle(angle);
        delta.mult(power);
        vel.add(delta);
      } else if (decelerating) {
        vel.mult(braking);
      }
      if (turningLeft) {
        angularVelocity += turnSpeed;
      }
      if (turningRight) {
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

  private void updateMarkerStatus() {
    for (int i = 0; i < markers.size(); i++) {
      Marker currentMarker = markers.get(i);
      if (currentMarker.colliding(this) && currentMarker.index != previousMarkerIndex) {
        if (currentMarker.index == previousMarkerIndex + 1) {
          fitness = currentMarker.score * currentMarker.score;
          ga.activity++;
          if (fitness > 1000) {
            ga.timeoutLimit = 20;
          }
          if (fitness > 4000) {
            ga.timeoutLimit = 30;
          }
          previousMarkerIndex = currentMarker.index;
        } else {
          if (previousMarkerIndex == 21 && currentMarker.index == 0) {
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
  private boolean notOnTrack() {
    int index0 = (int)pos.x + 7 + (int)pos.y * mapWidth;
    int index1 = (int)pos.x - 7 + (int)pos.y * mapWidth;
    int index2 = (int)pos.x + (int)(pos.y + 7) * mapWidth;
    int index3 = (int)pos.x + (int)(pos.y - 7) * mapWidth;
    boolean condition0 = index0 < 0 || index1 < 0 || index2 < 0 || index3 < 0;
    boolean condition1 = index0 >= myMap.pixels.length || index1 >= myMap.pixels.length || index2 >= myMap.pixels.length || index3 >= myMap.pixels.length;
    final int blackPixelValue = -16777216;
    if (!condition0 && !condition1) {
      if (myMap.pixels[index0] == blackPixelValue || myMap.pixels[index1] == blackPixelValue || myMap.pixels[index2] == blackPixelValue || myMap.pixels[index3] == blackPixelValue) {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  //setControls sets the inputs to car based on the neural networks output in the not manual mode
  private void setControls() {
    float[][] directions = neuralNetwork.feedForward(proximity);
    //println(directions[0][0] + "," + directions[1][0] + "," + directions[2][0] + "," + directions[3][0]);
    if (directions[0][0] >= 0.5) {
      accelerating = true;
    } else {
      accelerating = false;
    }
    if (directions[1][0] >= 0.5) {
      turningRight = true;
    } else {
      turningRight = false;
    }
    if (directions[2][0] >= 0.5) {
      decelerating = true;
    } else {
      decelerating = false;
    }
    if (directions[3][0] >= 0.5) {
      turningLeft = true;
    } else {
      turningLeft = false;
    }
  }

  //findDistance iterates over unit distances in the heading passed to it until it finds a wall or reaches the sensor end.
  private void findDistance(PVector heading, int index) {
    PVector posCopy = this.pos.copy();
    heading.setMag(1);
    for (int i = 0; i < proximitySensorLength; i++) {
      //updating the posCopy vector to point a unit further in the heading direction passed 
      posCopy.add(heading);
      //checking if the head of the posCopy vector lies in a wall
      if (myMap.pixels[(int)posCopy.x + ((int)posCopy.y) * mapWidth] == -16777216) {
        if (debugMode) {
          fill(255, 0, 0);
          ellipse(posCopy.x, posCopy.y, 5, 5);
        }
        //setting the proximity value to the iteration number aka distance in the heading direction
        proximity[index][0] = i / (float)proximitySensorLength;
        return;
      }
    }
    proximity[index][0] = 1.0;
  }

  //drawSensors uses cars angle heading to draw proximity sensors and pass arguments to the proximity findDistance function.
  private void drawSensors() {
    PVector heading = PVector.fromAngle(angle - PI / 6);
    heading.mult(proximitySensorLength);
    stroke(0, 0, 0, 100);
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

  public void renderCar() {
    if (!(!debugMode && dead)) {
      stroke(0);
      pushMatrix();
      switch(species) {
      case 1:// 1%
        fill(255, 255, 0, 150);
        break;
      case 2:// 3%
        fill(0, 0, 130, 150);
        break;
      case 3:
        // 8%
        fill(0, 255, 255, 150);
        break;
      case 4:
        // 20%
        fill(0, 0, 255, 150);
        break;
      case 5:
        // 100%
        fill(255, 0, 0, 150);
        break;
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
