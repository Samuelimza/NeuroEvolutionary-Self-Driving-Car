class Car{
  PVector pos;
  PVector vel;
  PVector acc;
  float heading;
  
  Car(int x, int y){
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
  }
  
  void update(){
    heading = vel.heading();
    vel.add(acc);
    pos.add(vel);
  }
  
  void move(){
    
  }
  
  void show(){
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(heading);
    rect(0, 0, 40, 20);
    popMatrix();
  }
}
