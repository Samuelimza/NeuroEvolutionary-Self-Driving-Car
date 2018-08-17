Car a = new Car(100, 100);
Car b = new Car(200, 200);

void setup(){
 size(400, 400);
 rectMode(CENTER);
 fill(255, 50, 50);
 noStroke();
 a.vel.y = 2;
 a.vel.x = 1;
}

void draw(){
 background(51);
 a.update();
 b.update();
 a.show();
 b.show();
}
