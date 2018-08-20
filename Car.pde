class Car{
  boolean acc = false, left = false, right = false;
  PVector pos;
  PVector vel;
  float drag = 0.98;
  float angle = 0;
  float angularVelocity = 0;
  float angularDrag = 0.9;
  float power = 0.05;
  float turnSpeed = 0.01;
  
  Car(int x, int y){
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
  }
  
  void update(){
    if(acc){
      PVector delta = PVector.fromAngle(angle);
      delta.mult(power);
      vel.add(delta);
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
  }
  
  void show(){
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    rect(0, 0, 20, 10);
    popMatrix();
  }
}
