void starsInit() {
  noStroke();//no outer circle on the ellipses

  for (int i = 1; i < maxSize; i++) {
    posS[i] = (PVector.random3D());
    posS[i].mult(mult); //multiply by the chosen amount to make stars spread out
    posS[i].add(midPoint);
  }
}

void starsDraw() {
  for (int i = 1; i < maxSize; i++) {
    pushMatrix();
    fill(255. - (float)i/maxSize*255, 225, 255);
    translate(posS[i].x, posS[i].y, posS[i].z);//move the origin to where we want the sphere
    float sizeS = random(size, size*2);
    ellipse(0, 0, sizeS, sizeS);

    //move to only the front hemisphere which we will see
    if (posS[i].z > 0) {
      posS[i].z *= -1;
    }

    popMatrix();
  }
}

//--------------- for asteroids ---------------------------------------------------------------------------------
void asteroidsInit() {
  asteroids.add(main);
}

void asteroidDraw() {

  for (int i = 0; i < asteroids.size(); i++) {
    //draw asteroids 
    if (asteroids.get(i) != main) {
      asteroids.get(i).update();
    } else {
      main.drawA();
    }
  }

  /*
  PVector midPoint2 = new PVector (0, 0, 0);//midpoint used for location of asteroid
   main.pos = midPoint2;
   */
}

void asteroidAdd() {

  for (int i = 0; i < AA; i++) {
    if (m4 - 6000*i >= 0 && mB6[i] == false) { //if six seconds has passed after game state has begun, (using method from enemy bullets and E.B.A(mount).), add an asteroid
      PVector location = new PVector(random(0-400, width+400), random(0-400, height+400), 0); //make location of new asteroid random
      new Asteroid(main, location);

      asteroidSound.trigger();//make bullet sound
      mB6[i] = true;
    }
  }
}

//------------ Game States ----------------------------------------------------------------------------------------------------------

void gameStatesDraw() {
  if (state == 0) {
    pregame();
  }
  //else if state = 1 then game
  if (state == 1 | state >= 10) {
    game();
  }
  //else if state = 2 than endgame
  if (state == 2) {
    endgame();
  }
}

void pregame() { //pregame screen
  background(0);
  image(asteroidImage, width/2+50, height/2+100, 100, 100); //draw image of an asteroid (just to make pregame look cool)
  image(ESHimage, width/2-150, height/2+70, 100, 100); //draw image of enemy ship (just to make pregame look cool)
  fill(255);
  textSize(60);
  text("Welcome To The Asteroids Game!", width/2, height/2-100);
  textSize(30);  
  text("Created by Ameen Walli-Attaei.", width/2, height/2-10);
  textSize(35);
  text("While in Game, press SPACE to access Paused Menu.", width/2, height/2+250);
  textSize(45);
  text("Press SPACE to continue to Game.", width/2, height/2+350);
  if (keyPressed && key == ' ') {
    state = 1; //if Space bar pressed, go to game
  }
}

void endgame() { //endgame screen and what to do when game ends
  fill(255);
  textSize(50);  
  text("Oh No! You Have Lost All of Your Lives! The Game has Ended!", width/2, height/2 - 100);
  text("Your score was: ", width/2-50, height/2 + 100);
  text("Press ENTER to retry.", width/2, height/2 + 700);
  fill(124, 252, 0);
  text(score, width/2+180, height/2 + 100);
  textSize(35);
  fill(255);
  text("Top 5 Scores:", width/2, height/2 + 200);
  fill(124, 252, 0);

  if (scoreAppended == false) { //add score and organize top scores array
    topScores = append(topScores, score); //add new score to the array
    topScores = sort(topScores); //sort array
    topScores = reverse(topScores); //reverse order of array so it is descending
    scoreAppended = true;
  }

  //also delete coins b/c they will be reset
  for (int i = 0; i < coins.size(); i++) {
    coins.remove(i);
  }

  //also delete all asteroids except for main for when game restarts
  for (int i = 0; i < asteroids.size(); i++) {
    if (asteroids.get(i) != main) {
      asteroids.remove(i);
    }
  }

  for (int i = 0; i < topScores.length; i++) {
    if (i >= 6) {
      topScores[i] = 0; //if the number in the top scores is the 6th or greater number than remove it b/c it is unecesary
    }
    text(topScores[i], width/2, height/2 + 250+i*50); //display scores
  }

  if (keyPressed && key == ENTER) { //if you press ENTER to restart game, then re initialze all components of game

    //do these actions once
    gameInitInGame(); //initialize some functions in the game state
    resetMB4MB6Boolean(); //reset booleans for ship bullets
    mB1 = false; //reset the boolean to false so the time when game starts can be recalculated when u return back to game
    gameInitInGame();
    initEverything();
  }

  //turn off all sounds
  nitrous.pause(); // else if thrust is not on, stop the nitrous sound
  bullet.stop();
  collision.stop();
}

//game() is in 'Game_Paused_HUD' tab
