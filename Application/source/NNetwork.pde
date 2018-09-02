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
  
  float[][] feedForward(float[][] input){
    float[][] l1 = matrixMult(weights[0], input);
    float[][] l2 = matrixMult(weights[1], l1);
    float[][] output = matrixMult(weights[2], l2);
    return output;
  }
  
  float[][] matrixMult(float[][] a, float[][] b){
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
