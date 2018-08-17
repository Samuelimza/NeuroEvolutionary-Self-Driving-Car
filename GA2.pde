Car a = new Car(100, 100);

void setup(){
 size(400, 400);
 rectMode(CENTER);
 fill(255, 50, 50);
 noStroke();
}

void draw(){
 background(51);
 a.update();
 a.show();
}

void keyPressed(){
  if(key == 'w'){
    a.acc = true;
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
  }
  if(key == 'd'){
    a.left = false;
  }
  if(key == 'a'){
    a.right = false;
  }
}
