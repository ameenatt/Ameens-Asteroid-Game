
void shipDrivingKeyP() {
  if (keyCode == LEFT) { //turning left
    leftBool = true;
  }
  if (keyCode == RIGHT) { //turning right
    rightBool = true;
  }
  if (keyCode == UP) { //going forward
    thrustBool = true;
  }
}

void shipDrivingKeyR() {
  if (keyCode == LEFT) {
    leftBool = false;
  }
  if (keyCode == RIGHT) {
    rightBool = false;
  }
  if (keyCode == UP) {
    thrustBool = false;
  }
}

//----------------- tracers ---------------------------------------------------------------------
void tracersInit() {
  for (int i = 0; i < maxSizeT; i++) {
    posT[i] = new PVector(-1000, -1000);
    velT[i] = PVector.random2D();
    velT[i].mult(velScale);
    accT[i] = new PVector(0, 0);

    sizes[i] = startSize;
  }
}

void tracers() {
  for (int i = maxSizeT -1; i > 0; i--) { //Move each tracer back in array
    posT[i] = posT[i-1];
    sizes[i] = sizes[i-1]*shrinkScale;  //Shrink tracer as moving through array
    velT[i] = velT[i-1];
  }

  if (thrustBool) {

    //if nitrous is off
    if (nitTriggered == false) { //trigger nitrous if it has not been turned on
      nitrous.loop();
      nitTriggered = true;
    }

    posT[0] = new PVector(posSH.x, posSH.y);
    velT[0] = PVector.random2D();
    velT[0].mult(velScale);
    sizes[0] = startSize;
  } else { //if not pressing thrust button, place tracers of screen
    posT[0] = new PVector(-1000, -1000);

    //stop the nos sound
    nitrous.pause(); // else if thrust is not on, stop the nitrous sound
    nitTriggered = false;
  }

  for (int i = 0; i < maxSizeT; i++) {
    posT[i].add(velT[i]);
    fill(255, 100 - (float)i/maxSizeT*254., 0, 255. - (float)i/15*254.);
    //fill(50 + (float)i/maxSizeT*205, 128+127*sin((float)frameCount* PI/60), 127. - cos((float)frameCount*PI/30), 255. - (float)i/maxSizeT*254.);
    pushMatrix();
    // println(dir);
    //translate(cos(dir)*speed, sin(dir)*speed);
    ellipse(posT[i].x, posT[i].y, sizes[i]/3, sizes[i]/3);
    popMatrix();
  }
}

//----------- off function for ship driving ----------------------------------------------------
void offEdge() {
  float x = edge-200;
  if (posSH.x > (width + x)) {
    posSH.x = 0 - x;
  } else if (posSH.x < 0 - x) {
    posSH.x = width + x;
  } 
  if (posSH.y > (height + x)) {
    posSH.y = 0 - x;
  } else if (posSH.y < 0 - x) {
    posSH.y = height + x;
  }
}

//----------------- bullets ---------------------------------------------------------------------
void bulletsKeyP() { //if 'B' is pressed and normal shooter is still on, add a bullet
  if (keyCode == 'B' && threeWayShooter == false) {
    posB.add(posSH.copy());
    PVector tempv = new PVector(sDir.x, sDir.y, sDir.z).mult(bulletSpeed);
    velB.add(tempv);

    bullet.trigger();//make bullet sound
  } else if (keyCode == 'B' && threeWayShooter == true) { //if 'B' is pressed and 3 way is on, add 3 bullets

    posB.add(posSH.copy());
    PVector tempv1 = new PVector(sDir.x, sDir.y, sDir.z).mult(bulletSpeed);
    tempv1.rotate(PI/6.0); //then for every third bullet rotate clockwise
    velB.add(tempv1);

    posB.add(posSH.copy());
    PVector tempv2 = new PVector(sDir.x, sDir.y, sDir.z).mult(bulletSpeed);
    velB.add(tempv2);

    posB.add(posSH.copy());
    PVector tempv3 = new PVector(sDir.x, sDir.y, sDir.z).mult(bulletSpeed);
    tempv3.rotate(-PI/6.0); //then for every third bullet rotate counter-clockwise
    velB.add(tempv3);

    bullet.trigger();//make bullet sound
  }
}

void bullets() {
  for (int i = 0; i < posB.size(); i++) {
    PVector p = posB.get(i);
    PVector v = velB.get(i);

    p.add(v);
    pushMatrix();
    translate(p.x, p.y, p.z);
    fill(255, 0, 0);
    sphere(bulletSize);
    popMatrix();
  }
}
//-------------- if ship hits asteroid, lose life -------------------------------------------------
void shipLoseLife1() {
  //if ship hits asteroid, then ship loses a life
  //but only if shield is off
  if (shield == false) {
    for (int i = 1; i < asteroids.size(); i++) {
      if (hitTarget(asteroids.get(i).pos, posSH, asteroids.get(i).siz, 25)) {
        posSH = new PVector(0, 0);
        lives -= 1;
        collision.trigger(); //make collision noise
      }
    }
  }
}

//-------------- if ship hits enemy bullet or enemy ship, then lose life -------------------------------------------------
void shipLoseLife2() {
  if (shield == false) {
    for (int i = 0; i < posEB.size(); i++) {
      if (hitTarget(posEB.get(i), posSH, 5, 25)) {
        posSH = new PVector(0, 0); // re locate ship
        lives -= 1; //make the ship lose a life
        collision.trigger(); //make collision noise
      }
    }
    PVector posESHI = posESH.copy(); //position of enemy image's center
    posESHI.add(50,50,0); //make it center of image
    if (hitTarget(posESHI, posSH, 50, 25)) {
      posSH = new PVector(0, 0); //re locate ship
      lives -= 1; //ship loses life
      collision.trigger(); //make collision noise
    }
  }
}
//----------------------- drawing ship driving ----------------------------------------------------
void shipDriving() {
  vel.add(acc);
  posSH.add(vel);
  fill(255); //colour of the ship
  pushMatrix();
  translate(posSH.x, posSH.y); //moving the ship to the new position
  // rotate(dir); //rotating the ship to face the desired direction
  rotate(sDir.heading()); //rotating the ship to face the desired direction
  stroke(0); //shade of stroke brings the stroke back
  box(30, 10, 10); //drawing the ship, which is a rectagular prism
  popMatrix();

  if (leftBool) {
    //dir -= 0.05; //rotate the ship to the left
    sDir.rotate(-0.05);
  }
  if (rightBool) {
    //dir += 0.05; //rotate the ship to the right
    sDir.rotate(0.05);
  }

  if (thrustBool) {
    //speed += 0.1; //increase the speed
    acc = sDir.copy().mult(0.05);
  } else {
    vel.mult(0.95);
    //speed *= 0.99; //reduce the speed over time
  }

  vel.limit(speedLimit);
  //speed = constrain(speed, 0, speedLimit); //limit the speed

  offEdge();
  shipLoseLife1();
  shipLoseLife2();
  shipGetLife();
  shipGetShield();
  shipGetCoin();
  shipGetBill();
}


//---------------------------- Enemy Ship Functions ----------------------------------------

void enemyShipInit() {
  posESH = new PVector (-410, -350);
  velESH = new PVector (0, 3);
}

void enemyShipDriving() {//draw enemy ship

  eBullets(); //create enemy bullets
  eBulletDraw(); //draw enemy bullets

  posESH.add(velESH);
  image(ESHimage, posESH.x, posESH.y, 100, 100);

  //create reoccuring path
  if (posESH.y > 1345) {
    velESH = new PVector (0, -3);
  }
  if (posESH.y < -350) {
    velESH = new PVector (0, 3);
  }
}



void eBullets() { //create enemy bullets
  
  m4 = realMillis; //the amount of time after game state has been turned on
  
  for (int i = 0; i < EBA; i++) {
    if (m4 - 1000*i >= 0 && mB4[i] == false) { //if one second has passed
      //if (millis() - m1 > i*1000 && mB4[i] == false) {
      PVector p = posESH.copy();
      p.x += 60; //move near the center of the ship in x axis
      p.y += 60; //move near the center of the ship in y axis
      posEB.add(p); //add the position once per minute

      velEB.add(new PVector (7, 0)); //initialize velocity

      bullet.trigger();//make bullet sound
      mB4[i] = true;
    }
  }
  
}

void eBulletDraw() { //draw the enemy bullet
  for (int i = 0; i < posEB.size(); i++) {

    PVector p = posEB.get(i); //get position
    PVector v = velEB.get(i); //get velocity

    v.x += 1; //add the velocity everytime

    p.add(v);
    pushMatrix();
    translate(p.x, p.y, p.z);
    fill(50, 205, 50);
    sphere(bulletSize);
    popMatrix();
  }
}

//---------------------------- deleteBullets() ----------------------------------------

void deleteBullets() { //if enemy/ship bullets go off screen, delete them to clear space
  
  for (int i = 0; i < posEB.size(); i ++) {
  float d = edge-200;
  PVector p = posEB.get(i);
  if (p.x > width + d || p.x < 0 - d || p.y > (height + d) || p.y < 0 - d) {
    posEB.remove(i);
    velEB.remove(i);
  }
  }
  
  for (int i = 0; i < posB.size(); i ++) {
  float d = edge-200;
  PVector p = posB.get(i);
  if (p.x > width + d || p.x < 0 - d || p.y > (height + d) || p.y < 0 - d) {
    posB.remove(i);
    velB.remove(i);
  }
  }
  
}
