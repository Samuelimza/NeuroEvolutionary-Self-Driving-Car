Car a = new Car(100, 100);
NNetwork n = new NNetwork();
PImage myMap;
PFont f;

void setup(){
 size(600, 600);
 f = createFont("Arial", 16, true);
 rectMode(CENTER);
 fill(255, 50, 50);
 noStroke();
 myMap = loadImage("Map.png");
 myMap.loadPixels();
 print(myMap.pixels[300 + 5 * 600]);
 /*
 println();
 for(int i = 0; i < n.weights.length; i++){
   for(int j = 0; j < n.weights[i].length; j++){
     for(int k = 0; k < n.weights[i][j].length; k++){
       print(n.weights[i][j][k]);
     }
     println();
   }
   println();
 }
 */
 println();
 
 float[][] testInput = new float[3][1];
 testInput[0][0] = 1.0;
 testInput[1][0] = 1.0;
 testInput[2][0] = 1.0;
 
 float[][] output = n.feedForward(testInput);
 for(int i = 0; i < 4; i++){
    println(output[i][0]);
 }
}

void draw(){
 //background(51);
 textFont(f, 30);
 stroke(4);
 fill(187, 252, 184, 150);
 text("X: " + a.pos.x + ", Y: " + a.pos.y, 10, 40);
 background(myMap);
 a.update();
 a.show();
}

void keyPressed(){
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
