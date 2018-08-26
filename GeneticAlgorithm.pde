class GeneticAlgorithm{
  float totalFitness;
  float maxFitness;
  int maxFitI;
  int generation = 0;
  
  void reproduce(){
    Car[] nextGenCars = new Car[noOfCars];
    for(int i = 0; i < cars.length; i++){
      nextGenCars[i] = new Car(370, 30);
      nextGenCars[i].neuralNetwork = new NNetwork(chooseParent().neuralNetwork);
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
  
  boolean saveGeneration(Car[] cars){
    JSONArray generationArray = new JSONArray();
    for(int carCounter = 0; carCounter < cars.length; carCounter++){
      JSONObject carJSON = new JSONObject();
      int weightCounter = 0;
      for(int i = 0; i < cars[carCounter].neuralNetwork.weights.length; i++){
        for(int j = 0; j < cars[carCounter].neuralNetwork.weights[i].length; j++){
          for(int k = 0; k < cars[carCounter].neuralNetwork.weights[i][j].length; k++){
            carJSON.setFloat("" + weightCounter, cars[carCounter].neuralNetwork.weights[i][j][k]);
            weightCounter++;
          }
        }
      }
      generationArray.setJSONObject(carCounter, carJSON);
    }
    saveJSONArray(generationArray, "generatons/" + generation + ".json");
    return true;
  }
  
  boolean loadGeneration(int generationToLoad){
    Car[] loadedCars = new Car[noOfCars];
    JSONArray generationArray = loadJSONArray("generations/" + generationToLoad + ".json");
    for(int carCounter = 0; carCounter < noOfCars; carCounter++){
      JSONObject carBrain = generationArray.getJSONObject(carCounter);
      int weightCounter = 0;
      for(int i = 0; i < cars[carCounter].neuralNetwork.weights.length; i++){
        for(int j = 0; j < cars[carCounter].neuralNetwork.weights[i].length; j++){
          for(int k = 0; k < cars[carCounter].neuralNetwork.weights[i][j].length; k++){
            loadedCars[carCounter].neuralNetwork.weights[i][j][k] = carBrain.getFloat("" + weightCounter);
            weightCounter++;
          }
        }
      }
    }
    cars = loadedCars;
    return true;
  }
}
