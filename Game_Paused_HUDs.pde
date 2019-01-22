
void game() {

  HUD1draw();

  if (state == 1) {
    //in game, go through all of these functions
    enemyShipDriving();
    bullets();
    starsDraw();
    asteroidDraw();
    tracers();
    shipDriving();
    pItemLifeDraw();
    pItemShield1Draw(); //draw shield pickup item
    pItemCoinDraw();
    pItemBillDraw();
    deleteBullets();
    asteroidAdd();

    gameInitInGame(); //initialize some functions in the game state

    //if space bar pressed, and the game state has been on for at least 0.5s go to paused screen
    if ((millis()-m1) > 500 && keyPressed && key == ' ') {
      state = 10;
      mB1 = false; //reset boolean so that it could be rechecked
    }
  }

  //run paused function
  paused();
  
  //if player loses all lives, then go to state 2 (endgame)
  if (lives == 0) {
    state = 2;
  }
}

void gameInitInGame () { //initialize some parts of the game (especially made for when leaving paused menu)

  if (mB1 == false) {
    m1 = millis(); //make m the time when the game state starts
    mB1 = true; //reset the boolean to true so time is not recalculated

    preRealMillis = millis(); //make preRealMillis start of game
  }

  realMillis = millis() - preRealMillis; //make realMillis time after game has started
}


void paused() {

  if (state == 10) { //if in paused menu

    //add error detection on paused selection  so you can only navigate between 1-3
    if (pausedSelection > 4) {
      pausedSelection = 4;
    }
    if (pausedSelection < 1) {
      pausedSelection = 1;
    }

    if (mB2 == false) { //make m the time when the paused state starts
      m2 = millis();
      mB2 = true;
    }
    //if space bar pressed, and at least 0.5s has passed, go back to the game
    if ((millis()-m2) > 1000 && keyPressed && key == ' ') {
      state = 1;
      mB2 = false; //reset the boolean to false so pressing space could work next time
      gameInitInGame(); //initialize some functions in the game state
      resetMB4MB6Boolean(); //reset booleans for ship bullets
      mB1 = false; //reset the boolean to false so the time when game starts can be recalculated when u return back to game
    }

    HUD2draw(); //draw HUD for paused menu
  }

  //if state is from 11-14, access a HUD for each possible selection
  if (state == 11) {
    topScores();
  } else if (state == 12) {
    shop();
  } else if (state == 13) {
    controls();
  } else if (state == 14) {
    instructions();
  }
}

//function to reset mB4 + mB6 booleans before leaving paused menu
void resetMB4MB6Boolean() { //reset the booleans for the enemy bullets and asteroids
  for (int i = 0; i < mB4.length; i++) {
    mB4[i] = false;
  }
  //(re)initialize mB6s to false
  for (int i = 0; i < AA; i++) {
    mB6[i] = false;
  }
}


void HUD1draw() { //this is the HUD for being in the game
  cam.beginHUD();
  textSize(20);
  fill(211, 211, 211, 128);
  rect(0, 0, width, 40);
  fill(169, 169, 169);
  text("SCORE: "+score, width/2+300, 18);
  text("Press SPACE to pause game.", width/2, 18);
  text("LIVES:", 40, 18);
  //draw hearts depending on the amount of lives
  if (lives >= 4) {
    image(heart1, 170, 8, 25, 25);
  }
  if (lives >= 3) {
    image(heart1, 140, 8, 25, 25);
  }
  if (lives >= 2) {
    image(heart1, 110, 8, 25, 25);
  } 
  if (lives >= 1) {
    image(heart1, 80, 8, 25, 25);
  }

  fill(124, 252, 0);
  text("$ "+money, 970, 18); //display money amount
  cam.endHUD();
}


void HUD2draw() { //HUD for the paused menu
  cam.beginHUD();

  textSize(50);
  fill(211, 211, 211);
  text("Game Paused", width/2, height/2-200);

  textSize(20);
  fill(211, 211, 211, 200);
  //if a selection is not being hovered over, then leave it grey
  text("Use arrow keys to navigate through the following selections. Press ENTER to select:", width/2, height/2);
  if (pausedSelection != 1) { 
    text("Top Scores", width/2, height/2+100);
  }
  if (pausedSelection != 2) {
    text("Shop", width/2, height/2+150);
  }
  if (pausedSelection != 3) { 
    text("Controls", width/2, height/2+200);
  }
  if (pausedSelection != 4) {
    text("Instructions", width/2, height/2+250);
  }
  text("Press SPACE to return to game.", width/2, height/2+350);
    
  //if hovering over a selection, highlight it yellow selection
  fill(255, 255, 0);
  if (pausedSelection == 1) {
    text("Top Scores", width/2, height/2+100);
  }
  if (pausedSelection == 2) {
    text("Shop", width/2, height/2+150);
  }
  if (pausedSelection == 3) {
    text("Controls", width/2, height/2+200);
  }
  if (pausedSelection == 4) {
    text("Instructions", width/2, height/2+250);
  }

  cam.endHUD();
}

void topScores() { //top scores screen
  cam.beginHUD();
  textSize(30);
  fill(211, 211, 211);
  text("Top Scores", width/2, height/2-200);
  textSize(20);
  fill(211, 211, 211, 200);

  //display all of the top scores
  for (int i = 0; i < topScores.length; i++) { //display the top scores
    text(topScores[i], width/2, height/2+100+50*i);
  }

  text("Press BACKSPACE to return to Paused Menu.", width/2, height/2+400);
  cam.endHUD();

  //if backspace is pressed, return to paused menu
  if (keyPressed && key == BACKSPACE) {
    state = 10;
  }
}

void controls() { //controls screen
  cam.beginHUD();
  textSize(30);
  fill(211, 211, 211);
  text("Controls", width/2, height/2-200);
  textSize(20);
  fill(211, 211, 211, 200);
  text("Press 'B' to shoot bullet.", width/2, height/2);
  text("Use arrow keys to move ship (Can't Go Backwards!):", width/2, height/2+50);
  text("UP = Move ship Forwards", width/2, height/2+100);
  text("LEFT = Rotate ship to the Left", width/2, height/2+150);
  text("RIGHT = Rotate ship to the Right", width/2, height/2+200);

  text("Press BACKSPACE to return to Paused Menu.", width/2, height/2+400);
  cam.endHUD();

  //if backspace is pressed, return to paused menu
  if (keyPressed && key == BACKSPACE) {
    state = 10;
  }
}

void shop() { //displaying shop menu

  cam.beginHUD();
  textSize(30);
  fill(211, 211, 211);
  text("Shop", width/2, height/2-200);
  textSize(20);

  //display possible selections
  fill(211, 211, 211, 200);
  if (shopSelection != 1) { 
    text("Buy 3 Way Shooter        $50", width/2, height/2+100);
  }
  if (shopSelection != 2) {
    text("Buy Life                         $10", width/2, height/2+150);
  }
  text("Press BACKSPACE to return to Paused Menu.", width/2, height/2+400);

  //if a selection is being hovered over, then highlight it yellow
  fill(255, 255, 0);
  if (shopSelection == 1) {
    text("Buy 3 Way Shooter        $50", width/2, height/2+100);
  }
  if (shopSelection == 2) {
    text("Buy Life                         $10", width/2, height/2+150);
  }
  cam.endHUD();

  //add error detection on shop selection so you can only navigate between options 1-2
  if (shopSelection > 2) {
    shopSelection = 2;
  }
  if (shopSelection < 1) {
    shopSelection = 1;
  }

  //if backspace is pressed, return to paused menu
  if (keyPressed && key == BACKSPACE) {
    state = 10;
  }
}

void instructions() {//displaying instructions menu

  cam.beginHUD();
  textSize(30);
  fill(211, 211, 211);
  text("Instructions", width/2, height/2-200);

  textSize(20);
  fill(211, 211, 211, 200);
  text("Shoot asteroids to get as many points as you can!", width/2, height/2+100);
  text("Try not get hit by asteroids, or the enemy ship or its bullets!", width/2, height/2+150);
  text("Pick up lives and shields to help you! And get money to buy advancements in the Shop!", width/2, height/2+200);
  text("Take turns playing with your friends to see who can get the highest score!", width/2, height/2+250);
  text("Press BACKSPACE to return to Paused Menu.", width/2, height/2+400);
  cam.endHUD();

  if (keyPressed && key == BACKSPACE) {
    state = 10;
  }
}
