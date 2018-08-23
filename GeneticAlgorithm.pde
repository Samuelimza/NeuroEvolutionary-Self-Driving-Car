class GeneticAlgorithm{
  float totalFitness;
  float maxFitness;
  int maxFitI;
  int generation = 0;
  
  void reproduce(){
    Car[] nextGenCars = new Car[noOfCars];
    for(int i = 0; i < cars.length; i++){
      nextGenCars[i] = chooseParent();
      mutate(nextGenCars[i]);
    }
    cars = nextGenCars;
    generation++;
  }
  
  Car chooseParent(){
    float luckyNumber = random(totalFitness);
    float runningSum = 0;
    for(int i = 0; i < cars.length; i++){
      runningSum += cars[i].fitness;
      if(runningSum >= luckyNumber){
        return cars[i];
      }
    }
    return new Car(370, 30);
  }
  
  void mutate(Car car){
    for(int i = 0; i < car.neuralNetwork.weights.length; i++){
      for(int j = 0; j < car.neuralNetwork.weights[i].length; j++){
        for(int k = 0; k < car.neuralNetwork.weights[i][j].length; k++){
          if(random(1) > car.mutationRate){
            car.neuralNetwork.weights[i][j][k] = (float)(Math.random() * 2 - 1);
          }
        }
      }
    }
  }
  
  boolean allDead(Car[] cars){
    for(int i = 0; i < cars.length; i++){
      if(!cars[i].dead){
        return false;
      }
    }
    return true;
  }
}
