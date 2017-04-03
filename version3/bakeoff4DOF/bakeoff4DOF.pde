import java.util.ArrayList;
import java.util.Collections;

int index = 0;

//your input code should modify these!!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;

int trialCount = 8; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
boolean placedRed = false;
boolean inRotation = false;
boolean inScale = false;
boolean fixRotation = false;
boolean fix = false;
float dist = 0;
float angle0 = 0;
float angle1 = 0;
float angleOffset = 0;
float a = 0;
float r = 50;
float xMark = 0;
float yMark = 0;

final int screenPPI = 72; //what is the DPI of the screen you are using 

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();
ArrayList<Target> grays = new ArrayList<Target>();

float inchesToPixels(float inch)
{
  return inch*screenPPI;
}

void setup() {
  size(700,700); 

  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.2f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);

  //don't change this! 
  border = inchesToPixels(.2f); //padding of 0.2 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    Target g = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    t.z = ((j%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0" 
    //g.x = random(-width/2+border*10, width/2-border*10);
    //g.y = random(-height/2+border*10, height/2-border*10);
    g.x = 0;
    g.y=0;
    g.rotation = 0;
    g.z = 10;
    targets.add(t);
    grays.add(g);
    if (i == 0) {
      float div = floor(t.rotation / 90);
      a = 90 - (t.rotation - div * 90);
      xMark = r*cos(radians(a));
      yMark = r*sin(radians(a));
    }
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}

void draw() {

  background(60); //background is dark grey
  fill(200);
  noStroke();
  
  fill(0);
  stroke(5);
  //line(0,350,700,350);
  
  //fill(255);
  //ellipse(400, 348, 5, 5);
  
  
  
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchesToPixels(.2f)*4);
    return;
  }

  Target g = grays.get(trialIndex);
  Target t = targets.get(trialIndex);
  
  dist = sqrt(sq(mouseX - (t.x + 350)) + sq(mouseY - (t.y+350)));
  
  
  //===========DRAW TARGET SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen

  //Target t = targets.get(trialIndex);
  
  //if(!placedRed){
  //  t.x = mouseX - width/2 - 50;
  //  t.y = mouseY - height/2;
  //}
  
  if(t.x == 0 && t.y == 0){
    text("The squares are aligned!", 0, -200);
  }
  
  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY); //center the drawing coordinates to the center of the screen
  
  rotate(radians(t.rotation));
  fill(255, 0, 0); //set color to semi translucent
 /* println("!!!!");
  println(t.x);
  println(t.y);
  println(g.x);
  println(g.y);*/
  boolean closeDist = dist(t.x,t.y,g.x,g.y)<inchesToPixels(.05f); //has to be within .1"
  if (closeDist) {
    fill(0,191,255);
  }
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
  if (closeDist && closeRotation) {
    fill(255,228,225);
  }
  boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"  
  if (closeDist && closeRotation && closeZ) {
    fill(127,255,0);
  }
  
  rect(0, 0, t.z, t.z);
  
  fill(255,255,0,100);
  stroke(1);
  ellipse(0, 0, 25, 25);

  popMatrix();

  //===========DRAW TARGETTING SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  rotate(radians(screenRotation));
  //custom shifts:
  //translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen
  
  
  fill(255, 128); //set color to semi translucent
  stroke(0);
  rect(g.x, g.y, screenZ, screenZ);
  
  fill(255,255,0,100);
  stroke(1);
  ellipse(g.x, g.y, 25, 25);
  
  fill(255, 255, 0);
  ellipse(xMark, yMark, 5,5);
  
  fill(255);
  ellipse(g.x + screenZ, g.y, 5, 5);
 
  popMatrix();

  //scaffoldControlLogic(); //you are going to want to replace this!
  
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
  
}

//my example design
void scaffoldControlLogic()
{
  //upper left corner, rotate counterclockwise
  text("CCW", inchesToPixels(.2f), inchesToPixels(.2f));
  if (mousePressed && dist(0, 0, mouseX, mouseY)<inchesToPixels(.5f))
    screenRotation--;

  //upper right corner, rotate clockwise
  text("CW", width-inchesToPixels(.2f), inchesToPixels(.2f));
  if (mousePressed && dist(width, 0, mouseX, mouseY)<inchesToPixels(.5f))
    screenRotation++;

  //lower left corner, decrease Z
  text("-", inchesToPixels(.2f), height-inchesToPixels(.2f));
  if (mousePressed && dist(0, height, mouseX, mouseY)<inchesToPixels(.5f))
    screenZ-=inchesToPixels(.02f);

  //lower right corner, increase Z
  text("+", width-inchesToPixels(.2f), height-inchesToPixels(.2f));
  if (mousePressed && dist(width, height, mouseX, mouseY)<inchesToPixels(.5f))
    screenZ+=inchesToPixels(.02f);

  //left middle, move left
  text("left", inchesToPixels(.2f), height/2);
  if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransX-=inchesToPixels(.02f);

  text("right", width-inchesToPixels(.2f), height/2);
  if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransX+=inchesToPixels(.02f);
  
  text("up", width/2, inchesToPixels(.2f));
  if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransY-=inchesToPixels(.02f);
  
  text("down", width/2, height-inchesToPixels(.2f));
  if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransY+=inchesToPixels(.02f);
  if(inRotation){
    text("IN ROTATION", 350, 200);
  }
  if(inScale){
    text("IN SCALE", 350, 200);
  }
}


void mousePressed()
{
    if (startTime == 0) //start time on the instant of the first user click
    {
      startTime = millis();
      println("time started!");
    }
}


void mouseClicked()
{
   //Target g = grays.get(trialIndex);
   //System.out.println("x: " + g.x + " y: " + g.y + " " + mouseX + " " + mouseY);
   
  //System.out.println(mouseX + " " + mouseY);
  //check to see if user clicked middle of screen
  //if (dist(g.x + 350 + (screenZ / 2), g.y + 350 + (screenZ / 2), mouseX, mouseY)<inchesToPixels(.5f))
  //{
    if(placedRed){
      System.out.println("clicked the gray square");
      if (userDone==false && !checkForSuccess())
        errorCount++;

      //and move on to next trial
      trialIndex++;
      placedRed = false;
      fix = false;
      
  
      screenTransX = 0;
      screenTransY = 0;
  
      if (trialIndex==trialCount && userDone==false)
      {
        userDone = true;
        finishTime = millis();
      } else {
        Target t = targets.get(trialIndex);
        float div = floor(t.rotation / 90);
        a = 90 - (t.rotation - div * 90);
        xMark = r*cos(radians(a));
        yMark = r*sin(radians(a));
      }
      
    }else if(placedRed == false){
    placedRed = true;
    Target t = targets.get(trialIndex);
    float x0 = mouseX - (t.x+350) == 0 ? mouseX - (t.x +350) : mouseX - (t.x + 350);
    float tan0 = ((pmouseY - (t.y + 350) )/ x0);
    angle0 = degrees(atan(tan0));
    }else if(placedRed && !fix){
      fix = true;
    }
    return;
  //} 
  
  
  
}

void mouseMoved(){
  //System.out.println(placedRed);
  if (userDone) return;
  Target t = targets.get(trialIndex);
  if(!placedRed){
    t.x = mouseX - width/2 - 50;
    t.y = mouseY - height/2;
  }else if(!fix){
    //t.rotation = angle;
    float x = mouseX - (t.x+350) == 0 ? mouseX - (t.x +350) : mouseX - (t.x + 350);
    float tan = ((mouseY - (t.y + 350) )/ x);
    angle1 = degrees(atan(tan));
    angleOffset = angle1 - angle0;
    angle0=angle1;
    t.rotation += angleOffset;
    println(t.rotation);
    println(a);
    println("#");
    t.z = dist;
  }
}

void mouseDragged(){
  Target t = targets.get(trialIndex);

    t.x = mouseX - width/2;
    t.y = mouseY - height/2;

}

public boolean checkForSuccess()
{
	Target t = targets.get(trialIndex);	
   Target g = grays.get(trialIndex);
	//boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f); //has to be within .1"
  boolean closeDist = dist(t.x,t.y,g.x,g.y)<inchesToPixels(.05f); //has to be within .1"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
	boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"	
	
  println("Close Enough Distance: " + closeDist);
  println("Close Enough Rotation: " + closeRotation + "(dist="+calculateDifferenceBetweenAngles(t.rotation,screenRotation)+")");
	println("Close Enough Z: " + closeZ);
	
	return closeDist && closeRotation && closeZ;	
}


double calculateDifferenceBetweenAngles(float a1, float a2)
  {
     double diff=abs(a1-a2);
      diff%=90;
      if (diff>45)
        return 90-diff;
      else
        return diff;
 }