class GeneticAlgorithm {
  float totalFitness;
  float maxFitness = -1;
  int maxFitI = -1;
  int generation = 0;

  int counter = 0;
  int activity = 0;
  int lastActivity = 0;
  int lastActivitySecond = second();
  int previousSecond = -1;
  int timeoutLimit = 8;

  int[] weightsChangedCounter = new int[5];
  float[] lastTenMaxFitnesses = new float[10];

  void update() {
    int second = second();
    if (second != previousSecond) {
      counter++;
      previousSecond = second;
    }
    if (activity != lastActivity) {
      lastActivity = activity;
      lastActivitySecond = second;
    }
    if (counter >= timeoutLimit) {
      reproduce();
      counter = 0;
      println("Reproduced Due to timeout");
    } else if (allDead(cars)) {
      reproduce();
      counter = 0;
      println("Reproduced Due to allDead");
    } else if (lastActivitySecond < second - 3) {
      reproduce();
      counter = 0;
      println("Reproduced due to No Activity");
    }
  }

  void reproduce() {
    maxFitness = 0;
    for (int i = 0; i < cars.length; i++) {
      if (cars[i].fitness > maxFitness) {
        maxFitness = cars[i].fitness;
        maxFitI = i;
      }
    }
    if (generation < 10) {
      lastTenMaxFitnesses[generation] = maxFitness;
    }
    println("MaxFitness: " + maxFitness);
    Car[] nextGenCars = new Car[noOfCars];
    if (maxFitI != -1) {
      nextGenCars[0] = new Car(370, 30, 1);
      nextGenCars[0].neuralNetwork = new NNetwork(cars[maxFitI].neuralNetwork);
      nextGenCars[0].isBest = true;
    } else {
      int species = (0 / (noOfCars / 5)) + 1;
      nextGenCars[0] = new Car(370, 30, species);
      nextGenCars[0].neuralNetwork = new NNetwork(chooseParent().neuralNetwork);
      weightsChangedCounter[nextGenCars[0].species - 1] += mutate(nextGenCars[0]);
    }
    for (int i = 1; i < cars.length; i++) {
      int species = (i / (noOfCars / 5)) + 1;
      nextGenCars[i] = new Car(370, 30, species);
      nextGenCars[i].neuralNetwork = new NNetwork(chooseParent().neuralNetwork);
      weightsChangedCounter[nextGenCars[i].species - 1] += mutate(nextGenCars[i]);
    }
    cars = nextGenCars;
    generation++;
    for (int i = 0; i < 5; i++) {
      println("Weights changed: " + weightsChangedCounter[i] / (noOfCars / 5) + ", species: " + i);
      weightsChangedCounter[i] = 0;
    }
    lastActivity = second();
  }

  Car chooseParent() {
    float luckyNumber = random(totalFitness);
    float runningSum = 0;
    for (int i = 0; i < cars.length; i++) {
      runningSum += cars[i].fitness;
      if (runningSum >= luckyNumber) {
        return cars[i];
      }
    }
    return new Car(370, 30, 1);
  }

  int mutate(Car car) {
    int counter = 0;
    for (int i = 0; i < car.neuralNetwork.weights.length; i++) {
      for (int j = 0; j < car.neuralNetwork.weights[i].length; j++) {
        for (int k = 0; k < car.neuralNetwork.weights[i][j].length; k++) {
          if (random(1) < car.mutationRate) {
            if (random(1) >= 0.5) {
              car.neuralNetwork.weights[i][j][k] += 0.1 * car.mutationRate * 100;
              counter++;
              //constrain(car.neuralNetwork.weights[i][j][k], -1, 1);
            } else {
              car.neuralNetwork.weights[i][j][k] -= 0.1 * car.mutationRate * 100;
              counter++;
              //constrain(car.neuralNetwork.weights[i][j][k], -1, 1);
            }
          }
        }
      }
    }
    //println("Weights changed: " + counter + ", species: " + car.species);
    return counter;
  }

  boolean allDead(Car[] cars) {
    for (int i = 0; i < cars.length; i++) {
      if (!cars[i].dead) {
        return false;
      }
    }
    return true;
  }

  boolean saveGeneration(Car[] cars) {
    JSONArray generationArray = new JSONArray();
    for (int carCounter = 0; carCounter < cars.length; carCounter++) {
      JSONObject carJSON = new JSONObject();
      int weightCounter = 0;
      for (int i = 0; i < cars[carCounter].neuralNetwork.weights.length; i++) {
        for (int j = 0; j < cars[carCounter].neuralNetwork.weights[i].length; j++) {
          for (int k = 0; k < cars[carCounter].neuralNetwork.weights[i][j].length; k++) {
            carJSON.setFloat("" + weightCounter, cars[carCounter].neuralNetwork.weights[i][j][k]);
            weightCounter++;
          }
        }
      }
      if (cars[carCounter].isBest) {
        carJSON.setString("isBest", "Yes");
      } else {
        carJSON.setString("isBest", "No");
      }
      generationArray.setJSONObject(carCounter, carJSON);
    }
    saveJSONArray(generationArray, "generatons/" + generation + ".json");
    return true;
  }

  boolean loadGeneration(int generationToLoad) {
    Car[] loadedCars = new Car[noOfCars];
    JSONArray generationArray = loadJSONArray("generations/" + generationToLoad + ".json");
    for (int carCounter = 0; carCounter < noOfCars; carCounter++) {
      JSONObject carBrain = generationArray.getJSONObject(carCounter);
      int weightCounter = 0;
      for (int i = 0; i < cars[carCounter].neuralNetwork.weights.length; i++) {
        for (int j = 0; j < cars[carCounter].neuralNetwork.weights[i].length; j++) {
          for (int k = 0; k < cars[carCounter].neuralNetwork.weights[i][j].length; k++) {
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
