//----------------------- money ----------------------------------
//--------- $5 bills ---------
void billInit() {
  //initialize $5 bill's position
      //create a PVector and give it a random location on the screen
      PVector p = new PVector (random(0-400, width+400), random(0-400, height+400), 0);
      
      //if it spawns near center asteroid, relocate
      if (p.x < width/2+10 && p.x > width/2-10 || p.y < height/2+10 && p.y > height/2-10){
        p = new PVector(100, 100, 0);
      }
      
      //add this Vector as a bill
      billPos = p;
}

void pItemBillDraw() {
  image(bill, billPos.x, billPos.y, 50, 50);
}

void shipGetBill() {
  //if ship hits $5 item, then...
  if (hitTarget(billPos, posSH, 40, 25)) {
    billInit(); //re-initialize coin's position
    money += 5; //add $5
    moneySound.trigger();//make sound
  }
}

//--------- $1 Coins ---------
void pItemCoinDraw() {

  //the time since game state has started
  m5 = realMillis;

  //create coins
  for (int i = 0; i < coinsAmount; i++) {
    if (m5 - 5000*i >= 0 && mB5[i] == false) {

      //initialize the position of a coin
      //create a PVector and give it a random location on the screen
      PVector p = new PVector (random(0-400, width+400), random(0-400, height+400), 0);
      
      //if it spawns near center asteroid, relocate
      if (p.x < width/2+10 && p.x > width/2-10 || p.y < height/2+10 && p.y > height/2-10){
        p = new PVector(100, 100, 0);
      }
      
      //add this Vector as a coin
      coins.add(p);

      mB5[i] = true;
      
    }
  }

  //draw coins
  for (int i = 0; i < coins.size(); i++) {
    image(coin, coins.get(i).x, coins.get(i).y, 30, 30);
  }

  shipGetCoin();

}

void shipGetCoin() {
  for (int i = 0; i < coins.size(); i++) {
    //if ship hits coin item, then...
    if (hitTarget(coins.get(i), posSH, 15, 25)) {
      coins.remove(i); //remove coin, add a dollar, and make sound
      money += 1;
      coinSound.trigger();
      coinsAmount += 1;
    }
  }
}

//----------------------- life item ----------------------------------

void pItemLifeInit() {
  //initialize the position of the life
      //create a PVector and give it a random location on the screen
      PVector p = new PVector (random(0-400, width+400), random(0-400, height+400), 0);
      
      //if it spawns near center asteroid, relocate
      if (p.x < width/2+10 && p.x > width/2-10 || p.y < height/2+10 && p.y > height/2-10){
        p = new PVector(100, 100, 0);
      }
      
      //add this Vector as the life
      lifePos = p;
}

void pItemLifeDraw() {
  image(heart1, lifePos.x, lifePos.y, 35, 35);
}

void shipGetLife() {

  //if ship hits life pickup item, then...
  if (hitTarget(lifePos, posSH, 20, 25) && lives < 4) {
    lives += 1; //ship gains life
    println("extra life"); 
    pItemLifeInit(); //re-initialize life pickup's position
    life.trigger(); //trigger life sound
  } else if (hitTarget(lifePos, posSH, 25, 25) && lives >= 4) {
    //but, if already at full life, then...
    pItemLifeInit(); //re-initialize life pickup's position
    life.trigger(); //trigger life sound
  }
}

//----------------------- shield item ----------------------------------

void pItemShieldInit() {
  //initialize the position of the shield
      //create a PVector and give it a random location on the screen
      PVector p = new PVector (random(0-400, width+400), random(0-400, height+400), 0);
      
      //if it spawns near center asteroid, relocate
      if (p.x < width/2+10 && p.x > width/2-10 || p.y < height/2+10 && p.y > height/2-10){
        p = new PVector(100, 100, 0);
      }
      
      //add this Vector to the shield
      shieldPos = p;
}

void pItemShield1Draw() { //draw shield pickup item
  image(shield1, shieldPos.x, shieldPos.y, 60, 60);
}

void pItemShield2Draw() { //draw shield around ship
  pushMatrix();
  noStroke();
  fill(0, 191, 255, 120);
  translate(posSH.x, posSH.y);
  sphere(25);
  popMatrix();
}

void shipGetShield() {
  
  //records the time from the start of the program until the shield turns on, or another shield is picked up
  if (shield == false || (millis() - mShield > 3 && hitTarget(shieldPos, posSH, 50, 25))) {
    mShield = millis(); //records the time when right before the shield turns on
  }

  //if ship hits shield pickup item, then...
  if (hitTarget(shieldPos, posSH, 30, 25)) {
    shield = true; //ship's shield turns on
    println("shield on");
    pItemShieldInit(); //re-initialize shield pickup's position
    shieldSound.trigger(); //trigger shield sound
  }

  if (shield == true) { //if shield is on then draw shield around ship
    pItemShield2Draw();
  }

  //if the shield has been on for 10000 mill. seconds, then turn of the shield (time difference between the time right now and when the shield turned on (mShield) must be 5s)
  if (millis() - mShield > 10000) {
    shield = false; //ship's shield turns on
  }

  //make shield make sound if it is about to go away
  if (millis() - mShield >= 8000 && millis() - mShield <= 10000) {
    beeping.play();
  } else if (millis() - mShield > 10000) {
    beeping.pause();
  }
}
