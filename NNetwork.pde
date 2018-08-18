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
  
  float[][] feedFoward(float[][] input){
    float[][] l1 = matrixMult(input, weights[0]);
    float[][] l2 = matrixMult(l1, weights[1]);
    float[][] output = matrixMult(l2, weights[2]);
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
