class NNetwork{
  int[] architecture = {3, 5, 4, 4};
  int[][][] weights = new int[3][][];

  NNetwork(){
    weights = new int[3][][];
    for(int i = 0; i < weights.length; i++){
      weights[i] = new int[this.architecture[i + 1]][this.architecture[i]];
    }
  }
  
  int[][] feedFoward(int[][] input){
    int[][] l1 = matrixMult(input, weights[0]);
    int[][] l2 = matrixMult(l1, weights[1]);
    int[][] output = matrixMult(l2, weights[2]);
    return output;
  }
  
  int[][] matrixMult(int[][] a, int[][] b){
    int[][] c = new int[a.length][b[0].length];
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
