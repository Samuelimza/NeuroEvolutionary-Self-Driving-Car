class Car{
  NNetwork neuralNetwork;
  boolean dead = false;
  boolean acc = false, left = false, right = false, decc = false;
  PVector pos;
  PVector vel;
  float drag = 0.98;
  float angle = PI;
  float angularVelocity = 0;
  float angularDrag = 0.925;
  float power = 0.05;
  float turnSpeed = 0.01;
  float braking = 0.95;
  float[][] proximity;
  
  Car(int x, int y){
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    proximity = new float[3][1];
    neuralNetwork = new NNetwork();
  }
  
  void update(){
    drawSensors();
    if(!manual){
      setControls();
    }
    if(acc){
      PVector delta = PVector.fromAngle(angle);
      delta.mult(power);
      vel.add(delta);
    }else if(decc){
      vel.mult(braking);
    }
    if(left){
      angularVelocity += turnSpeed;
    }
    if(right){
      angularVelocity -= turnSpeed;
    }
    pos.add(vel);
    vel.mult(drag);
    angle += angularVelocity;
    angularVelocity *= angularDrag;
    if(notOnTrack() && !manual){
      dead = true;
    }
  }
  
  //check for points near the periphery of the car that lie in the wall for collision detection
  boolean notOnTrack(){
    int index0 = (int)pos.x + 7 + (int)pos.y * width;
    int index1 = (int)pos.x - 7 + (int)pos.y * width;
    int index2 = (int)pos.x + (int)(pos.y + 7) * width;
    int index3 = (int)pos.x + (int)(pos.y - 7) * width;
    if(myMap.pixels[index0] == -16777216 || myMap.pixels[index1] == -16777216 || myMap.pixels[index2] == -16777216 || myMap.pixels[index3] == -16777216){
      return true;
    }
    return false;
  }
  
  //setControls sets the inputs to car based on the neural networks output in the not manual mode
  void setControls(){
    float[][] directions = neuralNetwork.feedForward(proximity);
    println(directions[0][0] + "," + directions[1][0] + "," + directions[2][0] + "," + directions[3][0]);
    if(directions[0][0] >= 0.5){
      acc = true;
    }else{
      acc = false;
    }
    if(directions[1][0] >= 0.5){
      right = true;
    }else{
      right = false;
    }
    if(directions[2][0] >= 0.5){
      decc = true;
    }else{
      decc = false;
    }
    if(directions[3][0] >= 0.5){
      left = true;
    }else{
      left = false;
    }
  }
  
  //findDistance iterates over unit distances in the heading passed to it until it finds a wall or reaches the sensor end.
  void findDistance(PVector heading, int index){
    PVector posCopy = this.pos.copy();
    heading.setMag(1);
    for(int i = 0; i < 100; i++){
      //updating the posCopy vector to point a unit further in the heading direction passed 
      posCopy.add(heading);
      //checking if the head of the posCopy vector lies in a wall
      if(myMap.pixels[(int)posCopy.x + ((int)posCopy.y) * width] == -16777216){
        fill(255, 0, 0);
        ellipse(posCopy.x, posCopy.y, 5, 5);
        //setting the proximity value to the iteration number aka distance in the heading direction
        proximity[index][0] = i / 100.0;
        return;
      }
    }
    proximity[index][0] = 1.0;
  }
  
  //drawSensors uses cars angle heading to draw proximity sensors and pass arguments to the proximity findDistance function.
  void drawSensors(){
    PVector heading = PVector.fromAngle(angle - PI / 6);
    heading.mult(100);
    stroke(200, 100, 60);
    //drawing for the -30 degree sensor
    line(pos.x, pos.y, pos.x + heading.x, pos.y + heading.y);
    findDistance(heading.copy(), 0);
    //drawing for the +30 degree sensor
    heading.rotate(PI / 3);
    line(pos.x, pos.y, pos.x + heading.x, pos.y + heading.y);
    findDistance(heading.copy(), 2);
    //drawing for the 0 degree sensor
    heading.rotate(-PI / 6);
    line(pos.x, pos.y, pos.x + heading.x, pos.y + heading.y);
    findDistance(heading.copy(), 1);
    //println(proximity[0][0] + ", " + proximity[1][0] + ", " + proximity[2][0]);
  }
  
  void show(){
    noStroke();
    pushMatrix();
    fill(255, 50, 50);
    translate(pos.x, pos.y);
    rotate(angle);
    rect(0, 0, 20, 10);
    popMatrix();
  }
}
