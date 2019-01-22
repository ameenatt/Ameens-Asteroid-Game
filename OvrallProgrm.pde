//for the camera
import peasy.*;
//the camera we will use
PeasyCam cam;

//for sound effects
import ddf.minim.*;
Minim minim;
AudioSample bullet;
AudioSample collision;
AudioPlayer nitrous;
AudioPlayer beeping;
AudioSample life;
AudioSample coinSound;
AudioSample moneySound;//for buying things in shop and getting $5
AudioSample asteroidSound; //for when an asteroid is spawned
AudioSample shieldSound; //sound when shield is picked up

//for the top 5 scores
int [] topScores = new int [0];
int score;
boolean scoreAppended;

//shield boolean
boolean shield;

//3 way shooter boolean
boolean threeWayShooter; //since weapon is not bought yet, keep it off (false)

int pausedSelection; //the int that will hold the number for which selection in the paused menu is accessed
int shopSelection; //the int that will hold the number for which selection in the shop menu is accessed

//images for lives
PImage heart1;
PImage shield1;
PImage shield2;
PImage coin;
PImage bill;
PImage asteroidImage;

//for stars
int maxSize = 100;//the number of stars
float mult = 2000;//the number you multiply the 3D sphere on which the stars exist by
float size = 10;//a number we select to use as the size of the spheres
PVector [] posS = new PVector[maxSize];//positions of the stars

//for Asteroids
Asteroid main;
ArrayList <Asteroid> asteroids = new ArrayList<Asteroid>();
PShape model;
PImage texture;
PVector center;

//midpoint used for camera's position
PVector midPoint;

//pickup items' positions
PVector lifePos;
PVector shieldPos;
int mShield; // records millies after program starts
//money related
ArrayList <PVector> coins = new ArrayList <PVector>(); //positions of the stars
int coinsAmount; //amount of coins
PVector billPos; //position of the 5 dollar bill item
int money; //int that holds amount of cash player has

//for ship driving
PVector posSH; //position of the ship
float dir; //direction the ship is facing
float speed; //speed of the ship
PVector vel;
PVector acc;
PVector sDir;
boolean leftBool, rightBool, thrustBool;
float speedLimit = 4;

//the # of lives (for the ship)
float lives;

//for tracers
int maxSizeT = 50;
float startSize; // this is the tracers starting size
PVector[] posT = new PVector[maxSizeT];
PVector[] velT = new PVector[maxSizeT];
PVector[] accT = new PVector[maxSizeT];
float [] sizes = new float[maxSizeT];
float shrinkScale;
float velScale;

//for enemy ship
PVector posESH; //position of the ship
PVector velESH;
PImage ESHimage;
//enemy ship bullets
int EBA = 3000;//maximum amount of enemy bullets
int AA = 500;//maximum amount of small asteroids
ArrayList <PVector> posEB = new ArrayList <PVector>(EBA);
ArrayList <PVector> velEB = new ArrayList <PVector>(EBA);

//millis booleans
boolean mB1; //for game state; used to check if millis for this state has been recorded yet
boolean mB2; //for paused state; used to check if millis for this state has been recorded yet
boolean mB3; //for shop state; used to check if millis for this state has been recorded yet
boolean [] mB4 = new boolean [EBA]; //for alien ship; used to check if millis for this state has been recorded yet
boolean [] mB5 = new boolean [100]; //for coins state; used to check if millis for this state has been recorded yet
boolean [] mB6 = new boolean [AA];
//millis ints
int m1; //records time (millis) when game state starts
int m2; //records time (millis) when paused state starts
int m3; //records time (millis) when shop state starts
int m4; //records time (millis) for when enemy bullet should shoot
int m5; //records time (millis) for when coins should add

//for bullets
ArrayList <PVector> velB = new ArrayList <PVector>();
ArrayList <PVector> posB = new ArrayList <PVector>();
float bulletSpeed = 25;
float bulletSize = 10;
boolean bulletsRotated; //checks if the bullets of the 3 way shooter have been rotated

//for game states
int state; //used to determine which state the the program is in; 0 = pregame; 1 = game; 2 = endgame;

//the distance of our camera from z = 0
float edge = 600;

int preRealMillis;
int realMillis;

//function for hitting targets
boolean hitTarget(PVector target, PVector bulletPos, float targetRad, float bulletRad) {
  return target.dist(bulletPos)<targetRad+bulletRad;
}

boolean nitTriggered = false; //for nitrous so that if it is playing, do not play again

void setup() {
  size(1000, 1000, P3D);//size of window
  frameRate(120);
  textSize(30);
  noStroke();
  textAlign(CENTER, CENTER);

  midPoint = new PVector(width/2, height/2, mult/2);
  cam = new PeasyCam(this, 0, 0, 0, 0); //initialize cam
  cam.lookAt(midPoint.x, midPoint.y, midPoint.z, edge, 0); //camera's position/view

  //Assign variables images
  heart1 = loadImage("heart3.png");
  shield1 = loadImage("power_up_shield.png");
  shield2 = loadImage("ShieldDrawing.png");
  coin = loadImage("coin_image.png");
  bill = loadImage("bill_image.png");
  ESHimage = loadImage("alien_ship_1.png");
  asteroidImage = loadImage("asteroidImgae.png");

  minim = new Minim(this); //initialize our minim
  //different sounds
   bullet = minim.loadSample("bullet.mp3"/*filename*/  , 512/*buffer size*/);
  collision = minim.loadSample( "collision2.mp3", 512);
  nitrous = minim.loadFile( "fire.mp3", 2048);
  beeping = minim.loadFile( "alarmclock.mp3", 2048);
  life = minim.loadSample("life.mp3", 512);
  coinSound = minim.loadSample("coin_sound.wav", 512);
  moneySound = minim.loadSample("money_sound.wav", 512);
  asteroidSound = minim.loadSample("Swooshing.mp3", 512);
  shieldSound = minim.loadSample("shieldSound.mp3", 512);

  //for Asteroid
  center = new PVector(width/2, height/2);
  texture = loadImage("texture2.jpg");
  model = loadShape("asteroid_2_2.obj");
  model.setTexture(texture);
  main = new Asteroid(asteroids, 20., model, center, new PVector(), false);

  asteroids.add(main);

  //initialize parts we need to re initialize when game restarts
  initEverything();
}


void initEverything() {
  //initialize some simple stuff
  pausedSelection = 1;
  shopSelection = 1;
  threeWayShooter = false;
  shield = false;
  money = 0;
  startSize = 30;
  dir = 0; //direction the ship is facing
  speed = 0; //speed of the ship
  m1 = 0;
  m2 = 0;
  m3 = 0;
  m4 = 0;
  m5 = 0;
  mB1 = false;
  mB2 = false;
  mB3 = false;
  shrinkScale = 0.99;
  velScale = 2;
  bulletsRotated = false;
  state = 0;
  lives = 4;
  leftBool = false;
  rightBool = false;
  thrustBool = false;
  coinsAmount = 3;
  scoreAppended = false;

  //for ship driving
  posSH = new PVector(width/4, height/4);
  vel = new PVector();
  acc = new PVector();
  sDir = new PVector(0, 1, 0);

  //initialize mB4s
  for (int i = 0; i < EBA; i++) {
    mB4[i] = false;
  }
  //initialize mB5s
  for (int i = 0; i < 100; i++) {
    mB5[i] = false;
  }
  //initialize mB5s
  for (int i = 0; i < AA; i++) {
    mB6[i] = false;
  }

  //for score
  score = 0;

  //initializing some parts of our program
  asteroidsInit();
  tracersInit();
  starsInit();
  enemyShipInit();
  pItemLifeInit();
  pItemShieldInit();
  billInit();
}


void keyPressed() {

  //when in game, go through the keys that control ship driving, and check if a bullet is shot
  if (state == 1) {
    shipDrivingKeyP();
    bulletsKeyP();
  }

  //for paused state:
  if (state == 10) {
    //add method of scrolling up and down
    if (keyCode == DOWN) {
      pausedSelection += 1;
    }
    if (keyCode == UP) {
      pausedSelection -= 1;
    }
    //if you select an option in the paused menu, switch to that state
    if (keyCode == ENTER) {
      if (pausedSelection == 1) {
        state = 11;
      } else if (pausedSelection == 2) {
        state = 12;
      } else if (pausedSelection == 3) {
        state = 13;
      } else if (pausedSelection == 4) {
        state = 14;
      }
    }
  }

  //for shop state
  if (state == 12) {
    if (mB3 == false) { //make m3 the time when the shop state starts
      m3 = millis();
      mB3 = true;
    }
    //add method of scrolling up and down
    if (keyCode == DOWN) {
      shopSelection += 1;
    }
    if (keyCode == UP) {
      shopSelection -= 1;
    }
    //if you select to buy an option from the shop menu (using ENTER), and at least 0.5s has passed since entering state, then buy it
    if ((millis()-m3) > 500 && keyCode == ENTER) {
      if (shopSelection == 1 && threeWayShooter == false && money >= 50) { //if they choose to buy 3 way shooter
        threeWayShooter = true; //activate three way shooter
        money -= 50; //lose $50
        moneySound.trigger();
      } else if (shopSelection == 2 && lives < 4 && money >= 10) { //if they choose to buy life
        lives += 1; //add life
        money -= 10; //lose $10
        moneySound.trigger();
      }
    }
  }
}

void keyReleased() {
  //in game, go through ship driving parts where key is relleased
  if (state == 1) {
    shipDrivingKeyR();
  }
}


void draw() {
  background(0);
  noStroke();
  println(lives);
  println(millis());

  gameStatesDraw();
}
