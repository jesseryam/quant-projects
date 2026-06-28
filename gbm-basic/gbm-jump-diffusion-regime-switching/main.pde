//Geometric Brownian Motion
ArrayList<Float> stockPrices = new ArrayList<>();
ArrayList<Float> stockFinal = new ArrayList<>();
ArrayList<Integer> regimes = new ArrayList<>();
ArrayList<Integer> jumpDaysList = new ArrayList<>();
ArrayList<Float> jumpSizesList = new ArrayList<>();
float mu = 0.07;
float sigma = 0.2;
float startPrice = 100;
float z = (float) randomGaussian();
//formula: P(t+1) = P(t) * e^( (mu - 0.5*sigma²)*dt + sigma*sqrt(dt)*Z )
/*Quarterly Days
 Day 63 — end of Q1
 Day 126 — end of Q2
 Day 189 — end of Q3
 Day 251 — end of Q4
 */
/*
If today is a LOW volatility day:
 
 Stays low volatility tomorrow: ~95%
 Switches to high volatility tomorrow: ~5%
 
 If today is a HIGH volatility day:
 
 Stays high volatility tomorrow: ~80%
 Switches back to low volatility tomorrow: ~20%
 */
float jumpMu = -0.02;
float jumpSigma = 0.08;
float z1 = (float) randomGaussian();
float jumpTerm=0;
int volatilityDeterminant = int(random(101));
void setup() {
  size(800, 600);
  background(20);
  stockPrices.add(0, startPrice);
  drawAxes();
  drawLegend();
}
void draw() {
  drawInstructions();
}
void runSim() {
  stockPrices.clear(); // clear old prices each run
  regimes.clear();
  jumpDaysList.clear();
  jumpSizesList.clear();
  stockPrices.add(startPrice);
  regimes.add(0);
  for (int i = 1; i < 252; i ++) {
    if (i == 63 || i == 126 || i == 189 ||i == 251) {
      jumpTerm = jumpMu + z1*jumpSigma;
      //println("Quarter Earning jump ", jumpTerm*100, "%");
      jumpDaysList.add(i);
      jumpSizesList.add(jumpTerm*100);
      z1 = (float) randomGaussian();
    } else {
      jumpTerm = 0;
    }
    volatilityDeterminant = int(random(101));
    if (sigma < 0.25) {
      if (volatilityDeterminant > 95) {
        sigma = random(0.25, 0.46) + 0.02 * abs(z);
        //println("volatitliy has gon from low to high", sigma);
      }
    } else {
      if (volatilityDeterminant < 20) {
        sigma = min(abs(random(0, 0.25) * z) + 0.05, 0.24);
        //println("volatitliy has gon from high to low", sigma);
      }
    }
    if (sigma >= 0.25) {
      regimes.add(1);
    } else {
      regimes.add(0);
    }
    z = (float) randomGaussian();
    stockPrices.add(stockPrices.get(i-1)*exp((mu - 0.5*(sigma*sigma))*1.0/252 + sigma*sqrt(1.0/252)*z + jumpTerm));
  }
  background(20);
  drawAxes();
  drawLegend();
  drawPricePath();
  drawEarningsMarkers();
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
  strokeWeight(1.5);
  for (int i = 1; i < stockPrices.size(); i++) {
    float x1 = map(i-1, 0, 251, 50, 750);
    float x2 = map(i, 0, 251, 50, 750);
    float y1 = map(stockPrices.get(i-1), 50, 200, 550, 50);
    float y2 = map(stockPrices.get(i), 50, 200, 550, 50);
    int regime = (i < regimes.size()) ? regimes.get(i) : 0;
    stroke(regime == 1 ? color(220, 60, 60) : color(30, 180, 100));
    line(x1, y1, x2, y2);
  }
  strokeWeight(1);
}
void drawEarningsMarkers() {
  for (int j = 0; j < jumpDaysList.size(); j++) {
    int day = jumpDaysList.get(j);
    float jumpPct = jumpSizesList.get(j);
    float x = map(day, 0, 251, 50, 750);
    stroke(255, 200, 0);
    strokeWeight(1);
    for (int y = 50; y < 555; y += 8) {
      line(x, y, x, y+4);
    }
    if (day < stockPrices.size()) {
      float py = map(stockPrices.get(day), 50, 200, 550, 50);
      fill(255, 200, 0);
      noStroke();
      ellipse(x, py, 7, 7);
      textSize(9);
      String label = (jumpPct >= 0 ? "+" : "") + nf(jumpPct, 1, 1) + "%";
      text(label, x+4, py-6);
    }
  }
}
void drawLegend() {
  fill(30);
  noStroke();
  rect(10, 10, 190, 95, 6);
  textSize(11);
  fill(30, 180, 100);
  rect(18, 22, 12, 12, 2);
  fill(200);
  text("Low volatility regime", 36, 33);
  fill(220, 60, 60);
  rect(18, 42, 12, 12, 2);
  fill(200);
  text("High volatility regime", 36, 53);
  stroke(255, 200, 0);
  strokeWeight(1.5);
  for (int y = 62; y < 74; y += 4) line(24, y, 24, y+2);
  fill(255, 200, 0);
  ellipse(24, 77, 6, 6);
  noStroke();
  fill(200);
  text("Earnings jump day", 36, 73);
  fill(120);
  textSize(9);
  text("GBM + Regime Switching + Jump Diffusion", 14, 95);
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
