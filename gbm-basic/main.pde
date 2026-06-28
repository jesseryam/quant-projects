//Geometric Brownian Motion
ArrayList<Float> stockPrices = new ArrayList<>();
ArrayList<Float> stockFinal = new ArrayList<>();
float mu = 0.07;
float sigma = 0.2;
float startPrice = 100;
float z = (float) randomGaussian();
//formula: P(t+1) = P(t) * e^( (mu - 0.5*sigma²)*dt + sigma*sqrt(dt)*Z )
void setup() {
  size(800, 600);
  background(20);
  stockPrices.add(0, startPrice);
  drawAxes();
}

void draw() {
  drawInstructions();
}

void runSim() {
  stockPrices.clear(); // clear old prices each run
  stockPrices.add(startPrice);
  for (int i = 1; i < 252; i ++) {
    z = (float) randomGaussian();
    stockPrices.add(stockPrices.get(i-1)*exp((mu - 0.5*(sigma*sigma))*1.0/252 + sigma*sqrt(1.0/252)*z));
  }
  drawPricePath();
}

void keyPressed() {
  runSim();
  printPrices();
}

void printPrices() {
  for (int i = 1; i < 253; i++) {
    println("day ", i, stockPrices.get(i-1));
  }
}

void drawInstructions() {
  // instruction box background
  fill(30);
  noStroke();
  rect(540, 45, 220, 115, 8);

  // title
  fill(255);
  textSize(12);

  text("Controls", 557, 63);

  // instructions

  textSize(11);
  fill(180);
  text("Press any key", 557, 82);
  fill(255);
  text("Run 1 simulation", 557, 96);

  fill(180);
  text("Click anywhere", 557, 114);
  fill(255);
  text("Run 10,000 simulations", 557, 128);
  textSize(11);
  fill(255, 0, 0);
  text("running 10,0000 simulations has some"+"\n"+" loading time", 557, 140);
}
void multiSimRun() {
  stockFinal.clear();
  float sum=0;
  float conditonal120 = 0;
  for (int i = 0; i < 10000; i ++) {
    runSim();
    stockFinal.add(stockPrices.get(251));
  }
  for (int i = 0; i < 10000; i++) {
    println(i, stockFinal.get(i));
    sum+=stockFinal.get(i);
    if (stockFinal.get(i) >= 120) {
      conditonal120++;
    }
  }
  println("MultiSimRun gave an estimated final day price of ", "$", sum/10000);
  println("MultiSimRun gave an estimated over 120 share price chace of ", conditonal120/100, "%");
}

void mousePressed() {
  multiSimRun();
}

void drawPricePath() {
  for (int i = 1; i < stockPrices.size(); i++) {
    float x1 = map(i-1, 0, 251, 50, 750);
    float x2 = map(i, 0, 251, 50, 750);
    float y1 = map(stockPrices.get(i-1), 50, 200, 550, 50);
    float y2 = map(stockPrices.get(i), 50, 200, 550, 50);
    stroke(#0037D6);
    line(x1, y1, x2, y2);
  }
}

void drawAxes() {
  stroke(150);
  strokeWeight(1);
  line(60, 560, 760, 560);
  line(60, 40, 60, 560);
  // labels
  fill(150);
  noStroke();
  textSize(11);
  text("Day 0", 55, 575);
  text("Day 252", 720, 575);
  text("$250", 10, 44);
  text("$40", 10, 564);
  text("$100", 10, map(100, 40, 250, 560, 40));
  stroke(100, 100, 100, 80);
  strokeWeight(0.5);
  line(60, map(100, 40, 250, 560, 40), 760, map(100, 40, 250, 560, 40));
}
