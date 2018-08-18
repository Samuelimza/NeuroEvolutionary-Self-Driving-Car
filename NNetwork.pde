class NNetwork{
  int[] architecture;
  int[][][] weights;
  
  NNetwork(int[] architecture){
    this.architecture = new int[architecture.length];
    for(int i = 0; i < this.architecture.length; i++){
      this.architecture[i] = architecture[i];
    }
    weights = new int[this.architecture.length - 1][][];
    for(int i = 0; i < weights.length; i++){
      weights[0] = new int[this.architecture[i + 1]][this.architecture[i]];
    }
  }
  
  int[][] feedFoward(int[][] input){
    int[][] l1;
    l1 = matrixMult(input, weights[0]);
    return l1;
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
