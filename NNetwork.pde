class NNetwork{
  int[] architecture;
  
  NNetwork(int[] architecture){
    this.architecture = new int[architecture.length];
    for(int i = 0; i < this.architecture.length; i++){
      this.architecture[i] = architecture[i];
    }
  }
}
