PImage skyImg, lifeImg, soldierImg, cabbageImg;
PImage soilEmpty, soil0, soil1, soil2, soil3, soil4, soil5, stone1, stone2;
PImage groundhogImg, groundhogDownImg, groundhogLeftImg, groundhogRightImg;
PImage titleImg, gameoverImg, startNormalImg, startHoveredImg, restartNormalImg, restartHoveredImg;
PImage[][] soils, stones;

final int GAME_START = 0;
final int GAME_RUN = 1;
final int GAME_OVER = 2;
int gameState = GAME_START;

final int BUTTON_TOP = 360;//detect button's position, change picture
final int BUTTON_BOTTOM = 420;
final int BUTTON_LEFT = 248;
final int BUTTON_RIGHT = 392;

int[][] soilHealth;

int x=0, y=0;//stone's position
//soldier,cabbage's position
float [] soldierX = new float[6];
float [] soldierY = new float[6];
float [] cabbageX = new float[6];
float [] cabbageY = new float[6];
int soldierSize;
int soldierSpeed;
float groundhogX;//groundhog's position
float groundhogY;
int groundhogSize;
final int SOIL_SIZE = 80;//to remove the offset
final int SOIL_COL_COUNT = 8;
final int SOIL_ROW_COUNT = 24;
int [] pos1 = new int[23];
int [] pos2 = new int[23];
int cabbageSize;

int hogState;//groundhog change position
boolean downPressed = false;
boolean leftPressed = false;
boolean rightPressed = false;
final int HOG_IDLE=1;
final int HOG_DOWN=2;
final int HOG_LEFT=3;
final int HOG_RIGHT=4;
float t;//groundhog move timer
float moveY=0;//roll the soil

int playerHealth;
final int PLAYER_MAX_HEALTH = 5;

boolean demoMode = false;

void setup() {
  size(640, 480, P2D);
  frameRate (60);

  //load the pictures
  skyImg = loadImage("img/bg.jpg");
  lifeImg = loadImage("img/life.png");
  soldierImg = loadImage("img/soldier.png");
  cabbageImg = loadImage("img/cabbage.png");
  groundhogImg = loadImage("img/groundhogIdle.png");
  groundhogDownImg = loadImage("img/groundhogDown.png");
  groundhogLeftImg = loadImage("img/groundhogLeft.png");
  groundhogRightImg = loadImage("img/groundhogRight.png");
  titleImg = loadImage("img/title.jpg");
  startNormalImg = loadImage("img/startNormal.png");
  startHoveredImg = loadImage("img/startHovered.png");
  restartNormalImg = loadImage("img/restartNormal.png");
  restartHoveredImg = loadImage("img/restartHovered.png");
  gameoverImg = loadImage("img/gameover.jpg");

  //lifeCount
  playerHealth = 2;

  //soil area
  soilEmpty = loadImage("img/soils/soilEmpty.png");

  // Load PImage[][] soils
  soils = new PImage[6][5];
  for (int i = 0; i < soils.length; i++) {
    for (int j = 0; j < soils[i].length; j++) {
      soils[i][j] = loadImage("img/soils/soil" + i + "/soil" + i + "_" + j + ".png");
    }
  }

  // Load PImage[][] stones
  stones = new PImage[2][5];
  for (int i = 0; i < stones.length; i++) {
    for (int j = 0; j < stones[i].length; j++) {
      stones[i][j] = loadImage("img/stones/stone" + i + "/stone" + i + "_" + j + ".png");
    }
  }

  // Initialize soilHealth
  soilHealth = new int[SOIL_COL_COUNT][SOIL_ROW_COUNT];
  for (int i = 0; i < soilHealth.length; i++) {
    for (int j = 0; j < soilHealth[i].length; j++) {
      // 0: no soil, 15: soil only, 30: 1 stone, 45: 2 stones
      soilHealth[i][j] = 15;
    }
  }

  //stone soilHealth part
  //stone 1-8
  for (int i=0; i<8; i++) {
    soilHealth[i][i]+=15;
  }

  //stone 9-16
  for (int i=0; i<8; i++) {
    for (int j=8; j<16; j++) {
      if (i==0 || i==3 || i==4 || i==7) {
        if (j==9 || j==10 || j==13 || j==14) {
          soilHealth[i][j]+=15;
        }
      } else if (j==8 || j==11 || j==12 || j==15) {
        soilHealth[i][j]+=15;
      }
    }
  }

  //stone 17-24
  for (int i=0; i<8; i++) {
    for (int j=16; j<24; j++) {
      if (i+j==17 || i+j==20 || i+j==23 || i+j==26 || i+j==29) {
        soilHealth[i][j]+=15;
      }
      if (i+j==18 || i+j==21 || i+j==24 || i+j==27 || i+j==30) {
        soilHealth[i][j]+=30;
      }
    }
  }

  //empty soil
  for (int i=0; i<23; i++) {
    for (int n=0; n<floor(random(1, 3)); n++) {
      //in one layer, pick positions
      if (n < 1) {
        pos1[i] = floor(random(8));
        soilHealth[pos1[i]][i+1] = 0;
        //println("ONE");
      } else {
        pos2[i] = floor(random(8));
        //soilHealth[pos1[i]][i+1] = 0;
        soilHealth[pos2[i]][i+1] = 0;
        //println("TWO");
      }
    }
  }

  //soldier
  for (int i=0; i<6; i++) {
    soldierX[i] = random(width);
    soldierY[i] = SOIL_SIZE*(2+i*4) + SOIL_SIZE*floor(random(0, 4));
    //println(soldierY[i]);
  }
  soldierSize = 80;
  soldierSpeed = 3;//soldier

  //groundhog
  groundhogX=320.0;
  groundhogY=80.0;
  groundhogSize=80;
  t=0.0;//groundhog change position
  hogState = HOG_IDLE;

  //cabbage
  for (int i=0; i<6; i++) {
    cabbageX[i] = SOIL_SIZE*floor(random(0, 8));
    cabbageY[i] = SOIL_SIZE*(2+i*4) + SOIL_SIZE*floor(random(0, 4));
  }
  cabbageSize=80;
}

void draw() {
  switch(gameState) {
  case GAME_START:
    image(titleImg, 0, 0);//start picture
    hogState=HOG_IDLE;
    t=0.0;
    downPressed=false;
    leftPressed=false;
    rightPressed=false;
    //detect button position
    if (mouseX > BUTTON_LEFT && mouseX < BUTTON_RIGHT
      && mouseY > BUTTON_TOP && mouseY < BUTTON_BOTTOM) {
      image(startHoveredImg, BUTTON_LEFT, BUTTON_TOP);
      if (mousePressed) {
        gameState = GAME_RUN;
      }
    } else {
      image(startNormalImg, BUTTON_LEFT, BUTTON_TOP);
    }
    break;

  case GAME_RUN:
    //background
    image(skyImg, 0, 0);//sky
    fill(253, 184, 19);//sun
    strokeWeight(5);
    stroke(255, 255, 0);
    ellipse(590, 50, 120, 120);

    if (moveY > -1600) {
      moveY=SOIL_SIZE-groundhogY;//a changing number(since the groundhogY is changing)
    }
    pushMatrix();
    translate(0, moveY);

    pushMatrix();
    translate(0, SOIL_SIZE*2);
    //soil
    for (int i = 0; i < soilHealth.length; i++) {
      for (int j = 0; j < soilHealth[i].length; j++) {
        // Change this part to show soil and stone images based on soilHealth value
        int areaIndex = floor(j / 4);
        image(soils[areaIndex][4], i * SOIL_SIZE, j * SOIL_SIZE);
      }
    }

    //stone 1-8
    for (int i=0; i<8; i++) {
      image(stones[0][4], i*SOIL_SIZE, i*SOIL_SIZE);
    }

    //stone 9-16
    for (int i=0; i<8; i++) {
      for (int j=8; j<16; j++) {
        if (i==0 || i==3 || i==4 || i==7) {
          if (j==9 || j==10 || j==13 || j==14) {
            image(stones[0][4], i*SOIL_SIZE, j*SOIL_SIZE);
          }
        } else if (j==8 || j==11 || j==12 || j==15) {
          image(stones[0][4], i*SOIL_SIZE, j*SOIL_SIZE);
        }
      }
    }

    //stone 17-24
    for (int i=0; i<8; i++) {
      for (int j=16; j<24; j++) {
        if (i+j==17 || i+j==20 || i+j==23 || i+j==26 || i+j==29) {
          image(stones[0][4], i*SOIL_SIZE, j*SOIL_SIZE);
        }
        if (i+j==18 || i+j==21 || i+j==24 || i+j==27 || i+j==30) {
          image(stones[0][4], i*SOIL_SIZE, j*SOIL_SIZE);
          image(stones[1][4], i*SOIL_SIZE, j*SOIL_SIZE);
        }
      }
    }

    //draw empty soil
    for (int i=0; i<23; i++) {
      if (soilHealth[pos1[i]][i+1] < 15) {
        image(soilEmpty, pos1[i]*SOIL_SIZE, (i+1)*SOIL_SIZE);
      }
      if (soilHealth[pos2[i]][i+1] < 15) {
        image(soilEmpty, pos2[i]*SOIL_SIZE, (i+1)*SOIL_SIZE);
      }
    }

    //if soilHealth == 0,HOG fall down
    for (int i=0; i<8; i++) {
      for (int j=0; j<23; j++) {
        if (hogState == HOG_IDLE && t == 0.0 && soilHealth[pos1[j]][j+1] ==0 && groundhogX == pos1[j]*SOIL_SIZE && groundhogY == (j+2)*SOIL_SIZE ) {
          hogState = HOG_DOWN;
          groundhogY += (80.0/15.0);
          t++;
        }
        if (hogState == HOG_IDLE && t == 0.0 && soilHealth[pos2[j]][j+1] ==0 && groundhogX == pos2[j]*SOIL_SIZE && groundhogY == (j+2)*SOIL_SIZE ) {
          hogState = HOG_DOWN;
          groundhogY += (80.0/15.0);
          t++;
        }
      }
    }


    // Demo mode: Show the value of soilHealth on each soil
    // (DO NOT CHANGE THE CODE HERE!)

    if (demoMode) {

      fill(255);
      textSize(26);
      textAlign(LEFT, TOP);

      for (int i = 0; i < soilHealth.length; i++) {
        for (int j = 0; j < soilHealth[i].length; j++) {
          text(soilHealth[i][j], i * SOIL_SIZE, j * SOIL_SIZE);
        }
      }
    }

    popMatrix();

    strokeWeight(15);//grass
    stroke(24, 204, 25);
    line(0, 152.5, 640, 152.5);

    //characters
    //cabbage
    for (int i=0; i<6; i++) {
      if (groundhogX < cabbageX[i]+cabbageSize &&//hog touch cabbage
        groundhogX+groundhogSize > cabbageX[i] &&
        groundhogY < cabbageY[i]+cabbageSize &&
        groundhogY+groundhogSize > cabbageY[i] &&
        playerHealth < PLAYER_MAX_HEALTH)
      {
        playerHealth+=1;
        cabbageX[i]=-80;//let cabbage out of the screen
        cabbageY[i]=-80;
      }
      image(cabbageImg, cabbageX[i], cabbageY[i]);
    }
    
    //Draw groundhog
    switch(hogState) {//control hog's state
    case HOG_IDLE:
      image(groundhogImg, groundhogX, groundhogY);
      t=0.0;
      break;

    case HOG_DOWN:
      image(groundhogDownImg, groundhogX, groundhogY);
      groundhogY += (80.0/15.0);
      t++;
      break;

    case HOG_LEFT:
      image(groundhogLeftImg, groundhogX, groundhogY);
      groundhogX -= (80.0/15.0);
      t++;
      break;

    case HOG_RIGHT:
      image(groundhogRightImg, groundhogX, groundhogY);
      groundhogX += (80.0/15.0);
      t++;
      break;
    }

    //groundhog boundary detection
    if (groundhogX > width-groundhogSize) {
      groundhogX = width-groundhogSize;
    }
    if (groundhogX < 0) {
      groundhogX = 0.0;
    }
    if (groundhogY > 160+24*SOIL_SIZE-groundhogSize) {
      groundhogY = 160+24*SOIL_SIZE-groundhogSize;
    }
    if (groundhogY < 80) {
      groundhogY = 80.0;
    }

    //hog move timer (the remove offset program must put between after move & before detect object bump)
    if (t==15.0) {
      hogState=HOG_IDLE;
      if (groundhogX%SOIL_SIZE < 10) {//remove the offset
        groundhogX=groundhogX-groundhogX%SOIL_SIZE;
      } else {
        groundhogX=groundhogX-groundhogX%SOIL_SIZE+SOIL_SIZE;//remove the float one, add the right number
      }
      if (groundhogY%SOIL_SIZE < 10) {//remove the offset
        groundhogY=groundhogY-groundhogY%SOIL_SIZE;
      } else {
        groundhogY=groundhogY-groundhogY%SOIL_SIZE+SOIL_SIZE;
      }
    }
    //hog touch soldier
    for (int i=0; i<6; i++) {
      if (groundhogX < soldierX[i]+soldierSize &&
        groundhogX+groundhogSize > soldierX[i] &&
        groundhogY < soldierY[i]+soldierSize &&
        groundhogY+groundhogSize > soldierY[i])
      {
        playerHealth-=1;
        groundhogX=320.0;
        groundhogY=80.0;
        hogState=HOG_IDLE;
        moveY=0;
      }
    }
    
    //Draw soldier
    for (int i=0; i<6; i++) {
      image(soldierImg, soldierX[i], soldierY[i]);
      soldierX[i] += soldierSpeed;//soldier Walking Speed
      if (soldierX[i] > 640) {
        soldierX[i] = -80;
        soldierX[i] += soldierSpeed;
      }
    }

    popMatrix();


    //playerHealth (size: 50*43) game change; gap=20pixel
    if (playerHealth >= PLAYER_MAX_HEALTH){
      playerHealth = PLAYER_MAX_HEALTH;
    }
    for (int i=0; i<playerHealth; i++) {
      image(lifeImg, 10+i*70, 10);
    }
    if (playerHealth == 0) {
      gameState = GAME_OVER;
    }


    break;

  case GAME_OVER:
    image(gameoverImg, 0, 0);//gameover picture
    downPressed=false;
    leftPressed=false;
    rightPressed=false;
    //detect button position
    if (mouseX > BUTTON_LEFT && mouseX < BUTTON_RIGHT
      && mouseY > BUTTON_TOP && mouseY < BUTTON_BOTTOM) {
      image(restartHoveredImg, BUTTON_LEFT, BUTTON_TOP);
      if (mousePressed) {
        gameState = GAME_RUN;
        playerHealth = 2;

        moveY=0;

        groundhogX=320.0;
        groundhogY=80.0;
        hogState=HOG_IDLE;
        t=0.0;

        for (int i=0; i<6; i++) {
          soldierX[i] = random(width);
          soldierY[i] = SOIL_SIZE*(2+i*4) + SOIL_SIZE*floor(random(0, 4));
          cabbageX[i] = SOIL_SIZE*floor(random(0, 8));
          cabbageY[i] = SOIL_SIZE*(2+i*4) + SOIL_SIZE*floor(random(0, 4));
        }


        //empty soil
        for (int i=0; i<23; i++) {
          for (int n=0; n<floor(random(1, 3)); n++) {
            //in one layer, pick positions
            if (n < 1) {
              pos1[i] = floor(random(8));
              soilHealth[pos1[i]][i+1] = 0;
              //println("ONE");
            } else {
              pos2[i] = floor(random(8));
              soilHealth[pos2[i]][i+1] = 0;
              //println("TWO");
            }
          }
        }
      }
    } else {
      image(restartNormalImg, BUTTON_LEFT, BUTTON_TOP);
    }
    break;
  }
}

void keyPressed() {
  if (key==CODED) {
    switch (keyCode) {
    case DOWN:
      if (hogState == HOG_IDLE) {
        downPressed=true;
        hogState = HOG_DOWN;
        t=0.0;
      }
      break;
    case LEFT:
      if (hogState == HOG_IDLE) {
        leftPressed=true;
        hogState = HOG_LEFT;
        t=0.0;
      }
      break;
    case RIGHT:
      if (hogState == HOG_IDLE) {
        rightPressed=true;
        hogState = HOG_RIGHT;
        t=0.0;
      }
      break;
    }
  } else {
    if (key=='b') {
      // Press B to toggle demo mode
      demoMode = !demoMode;
    }
  }
}
