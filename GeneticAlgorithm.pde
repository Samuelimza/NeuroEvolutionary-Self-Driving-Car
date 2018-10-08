public class GeneticAlgorithm { //<>//
  private MessageFormat loadSavePathFormatter;

  private float totalFitness;
  private float maxFitness = -1;
  private int maxFitnessIndex = -1;
  public int generation = 0;

  private int counter = 0;
  public int activity = 0;
  private int lastActivity = 0;
  private int lastActivitySecond = second();
  private int previousSecond = -1;
  public int timeoutLimit = 8;

  private float[] lastTenMaxFitnesses = new float[10];

  public GeneticAlgorithm() {
    loadSavePathFormatter = new MessageFormat("generations/metaDataGens/{0}.json");
  }

  public void updateGeneticAlgorithmState() {
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

  private float findMaxFitnessAndIndex() {
    for (int i = 0; i < cars.length; i++) {
      if (cars[i].fitness > maxFitness) {
        maxFitness = cars[i].fitness;
        maxFitnessIndex = i;
      }
    }
    if (generation < 10) {
      lastTenMaxFitnesses[generation] = maxFitness;
    }
    println("MaxFitness: " + maxFitness);
    return maxFitness;
  }

  public void reproduce() {
    Car[] nextGenCars = new Car[noOfCars];
    maxFitness = findMaxFitnessAndIndex();
    if (maxFitnessIndex != -1) {
      //If there is a maxFitness car, copy it as it is
      nextGenCars[0] = new Car(370, 30, 1);
      if (track == 3) {
        nextGenCars[0].pos.y = startY[1];
      }
      nextGenCars[0].neuralNetwork = new NNetwork(cars[maxFitnessIndex].neuralNetwork);
      nextGenCars[0].isBest = true;
    } else {
      //If there isn't then fill index 0 by a random generated
      int species = (((0 / (noOfCars / 5)) + 1) > 5) ? 5 : ((0 / (noOfCars / 5)) + 1);
      nextGenCars[0] = new Car(370, 30, species);
      if (track == 3) {
        nextGenCars[0].pos.y = startY[1];
      }
      nextGenCars[0].neuralNetwork = new NNetwork(chooseParent().neuralNetwork);
      mutate(nextGenCars[0]);
    }
    for (int i = 1; i < cars.length; i++) {
      int species = (((i / (noOfCars / 5)) + 1) > 5) ? 5 : ((i / (noOfCars / 5)) + 1);
      ;
      nextGenCars[i] = new Car(370, 30, species);
      if (track == 3) {
        nextGenCars[i].pos.y = startY[1];
      }
      nextGenCars[i].neuralNetwork = new NNetwork(chooseParent().neuralNetwork);
      mutate(nextGenCars[i]);
    }
    cars = nextGenCars;
    generation++;
    lastActivity = second();
  }

  private Car chooseParent() {
    float luckyNumber = random(totalFitness);
    float runningSum = 0;
    for (int i = 0; i < cars.length; i++) {
      runningSum += cars[i].fitness;
      if (runningSum >= luckyNumber) {
        return cars[i];
      }
    }
    if (track == 3) {
      return new Car(370, startY[1], 1);
    }
    return new Car(370, 30, 1);
  }

  private int mutate(Car car) {
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

  private boolean allDead(Car[] cars) {
    for (int i = 0; i < cars.length; i++) {
      if (!cars[i].dead) {
        return false;
      }
    }
    return true;
  }

  public void setTestingCar() {
    testingCar = new Car(370, 30, 1);
    if (track == 3) {
      testingCar.pos.y = startY[1];
    }
    for (int bestCarFindingIndex = 0; bestCarFindingIndex < cars.length; bestCarFindingIndex++) {
      if (cars[bestCarFindingIndex].isBest) {
        testingCar.neuralNetwork = new NNetwork(cars[bestCarFindingIndex].neuralNetwork);
        testingCar.isBest = true;
        break;
      }
    }
  }

  private JSONObject metaDataJSONObject() {
    JSONObject metaData = new JSONObject();
    metaData.setInt("Generation", generation);
    metaData.setFloat("drag", cars[0].drag);
    metaData.setFloat("angularDrag", cars[0].angularDrag);
    metaData.setFloat("power", cars[0].power);
    metaData.setFloat("turnSpeed", cars[0].turnSpeed);
    metaData.setFloat("braking", cars[0].braking);
    metaData.setInt("proximitySensorLength", cars[0].proximitySensorLength);
    return metaData;
  }

  public void saveGeneration(Car[] cars, String saveName) {
    JSONArray generationArray = new JSONArray();
    JSONObject metaData = metaDataJSONObject();
    generationArray.setJSONObject(0, metaData);
    for (int carCounter = 0; carCounter < cars.length; carCounter++) {
      JSONObject carJSON = new JSONObject();
      int weightCounter = 0;
      for (int i = 0; i < cars[carCounter].neuralNetwork.weights.length; i++) {
        for (int j = 0; j < cars[carCounter].neuralNetwork.weights[i].length; j++) {
          for (int k = 0; k < cars[carCounter].neuralNetwork.weights[i][j].length; k++) {
            carJSON.setFloat(str(weightCounter), cars[carCounter].neuralNetwork.weights[i][j][k]);
            weightCounter++;
          }
        }
      }
      carJSON.setBoolean("isBest", cars[carCounter].isBest);
      generationArray.setJSONObject(carCounter + 1, carJSON);
    }
    saveJSONArray(generationArray, loadSavePathFormatter.format(new Object[] {saveName}));
  }

  public void loadGeneration(String generationToLoad) {
    JSONArray generationArray = loadJSONArray(loadSavePathFormatter.format(new Object[] {generationToLoad}));
    JSONObject metaData = generationArray.getJSONObject(0);
    float tempDrag = 0, tempAngularDrag = 0, tempPower = 0, tempTurnSpeed = 0, tempBraking = 0;
    int tempProximitySensorLength = 0;
    boolean metaDataAvailable = true;
    try {
      generation = metaData.getInt("Generation");
      tempDrag = metaData.getFloat("drag");
      tempAngularDrag = metaData.getFloat("angularDrag");
      tempPower = metaData.getFloat("power");
      tempTurnSpeed = metaData.getFloat("turnSpeed");
      tempBraking = metaData.getFloat("braking");
      tempProximitySensorLength = metaData.getInt("proximitySensorLength");
    }
    catch(Exception RuntimeException) {
      metaDataAvailable = false;
    }
    noOfCars = generationArray.size() - 1;
    Car[] loadedCars = new Car[noOfCars];
    for (int carCounter = 0; carCounter < noOfCars; carCounter++) {
      loadedCars[carCounter] = new Car(370, 30, 1);
      if (track == 3) {
        loadedCars[carCounter].pos.y = startY[1];
      }
      if (metaDataAvailable) {
        loadedCars[carCounter].drag = tempDrag;
        loadedCars[carCounter].angularDrag = tempAngularDrag;
        loadedCars[carCounter].turnSpeed = tempTurnSpeed;
        loadedCars[carCounter].power = tempPower;
        loadedCars[carCounter].braking = tempBraking;
        loadedCars[carCounter].proximitySensorLength = tempProximitySensorLength;
      }
      JSONObject carBrain = generationArray.getJSONObject(carCounter + 1);
      try {
        loadedCars[carCounter].isBest = carBrain.getBoolean("isBest");
      }
      catch(Exception NullPointerException) {
      }
      int weightCounter = 0;
      for (int i = 0; i < cars[carCounter].neuralNetwork.weights.length; i++) {
        for (int j = 0; j < cars[carCounter].neuralNetwork.weights[i].length; j++) {
          for (int k = 0; k < cars[carCounter].neuralNetwork.weights[i][j].length; k++) {
            loadedCars[carCounter].neuralNetwork.weights[i][j][k] = carBrain.getFloat(str(weightCounter));
            weightCounter++;
          }
        }
      }
    }
    cars = loadedCars;
  }
}
