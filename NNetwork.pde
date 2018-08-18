class NNetwork{
  int[] architecture;
  
  NNetwork(int[] architecture){
    this.architecture = new int[architecture.length];
    for(int i = 0; i < this.architecture.length; i++){
      this.architecture[i] = architecture[i];
    }
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
