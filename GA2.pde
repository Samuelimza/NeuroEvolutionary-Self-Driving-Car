Car a = new Car(100, 100);
NNetwork n = new NNetwork();
PImage map;

void setup(){
 size(600, 600);
 rectMode(CENTER);
 fill(255, 50, 50);
 noStroke();
 map = loadImage("Map.png");
 map.loadPixels();
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
 println();
 */
 
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
 background(map);
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
