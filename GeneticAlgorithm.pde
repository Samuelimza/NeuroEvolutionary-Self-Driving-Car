class GeneticAlgorithm{
  float totalFitness;
  float maxFitness = -1;
  int maxFitI = -1;
  int generation = 0;

  int counter = 0;
  int previousSecond = -1;
  int timeoutLimit = 8;
  
  void update(){
    int second = second();
    if(second != previousSecond){
      counter++;
      previousSecond = second;
    }
    if(counter == timeoutLimit){
      reproduce();
      counter = 0;
    }else if(allDead(cars)){
      reproduce();
    }
  }
  
  void reproduce(){
    maxFitness = 0;
    for(int i = 0; i < cars.length; i++){
      if(cars[i].fitness > maxFitness){
        maxFitness = cars[i].fitness;
        maxFitI = i;
      }
    }
    println("MaxFitness: " + maxFitness);
    Car[] nextGenCars = new Car[noOfCars];
    nextGenCars[0] = new Car(370, 30);
    nextGenCars[0].neuralNetwork = new NNetwork(cars[maxFitI].neuralNetwork);
    nextGenCars[0].isBest = true;
    for(int i = 1; i < cars.length; i++){
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
            if(random(1) >= 0.5){
              car.neuralNetwork.weights[i][j][k] += 0.1;
              constrain(car.neuralNetwork.weights[i][j][k], -1, 1);
            }else{
              car.neuralNetwork.weights[i][j][k] -= 0.1;
              constrain(car.neuralNetwork.weights[i][j][k], -1, 1);
            }
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
