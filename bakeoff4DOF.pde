import java.util.ArrayList;
import java.awt.event.MouseEvent;
import java.awt.Point;
import java.util.Collections;
import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;
import java.awt.Toolkit;
import java.awt.Point;
import java.awt.Component;
import java.awt.AWTException;
import java.awt.event.MouseEvent;
import java.awt.*;
import java.awt.event.*;

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

boolean overRotationCircle = false;
boolean rotationLocked = false;
float rotationOffset = 0.0;

boolean overScaleCircle = false;
boolean scaleLocked = false;
float scaleOffset = 0.0;

final int screenPPI = 72; //what is the DPI of the screen you are using 

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

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
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    t.z = ((j%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0" 
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}

void draw() {

  background(60); //background is dark grey
  fill(200);
  noStroke();

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchesToPixels(.2f)*4);
    return;
  }

  //===========DRAW TARGET SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  
  Target t = targets.get(trialIndex);
  
 
  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY); //center the drawing coordinates to the center of the screen
  rotate(radians(t.rotation));

  fill(255, 0, 0); //set color to semi translucent
  rect(0, 0, t.z, t.z);
  stroke(255);
  
  // Rotation line and rotation circle
  line(0, 0, 0, 0-t.z/2-100);
  ellipse(0, 0-t.z/2-100, 10, 10);
  
  // Test if the cursor is over the rotation circle
  float len = t.z/2+100;
  float circleX = width/2+t.x+screenTransX+len*sin(radians(t.rotation));
  float circleY = height/2+t.y+screenTransY-len*cos(radians(t.rotation));
  float offset = 20;
  if (mouseX > circleX-offset && mouseX < circleX+offset && 
      mouseY > circleY-offset && mouseY < circleY+offset) {
    overRotationCircle = true;  
  } else {
    overRotationCircle = false;
  }
  
  fill(0, 255, 0);
  ellipse(t.z/2, -t.z/2, 10, 10);
  // Test if the cursor is over the scale circle
  float scale_len = sqrt(2)*t.z/2;
  float scaleX = width/2+t.x+screenTransX+scale_len*sin(radians(t.rotation+45));
  float scaleY = height/2+t.y+screenTransY-scale_len*cos(radians(t.rotation+45));
  if (mouseX > scaleX-offset && mouseX < scaleX+offset && 
      mouseY > scaleY-offset && mouseY < scaleY+offset) {
    overScaleCircle = true;  
  } else {
    overScaleCircle = false;
  }
  stroke(0);
  popMatrix();

  //===========DRAW TARGETTING SQUARE=================
  pushMatrix();

  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  rotate(radians(screenRotation));
  //custom shifts:
  //translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen
  fill(255, 128); //set color to semi translucent
  rect(0, 0, screenZ, screenZ);
  stroke(255);
  line(0, 0, 0, 0-screenZ-100);
  stroke(0);
  fill(255,255,100);
  ellipse(0,0,3,3);
  fill(255);
  popMatrix();
  
  // Confirm to match
  stroke(0);
  fill(255,0);
  rect(width/2, height-10, 200, 20);
  fill(255);
  text("Proceed to match", width/2, height-5);
 // scaffoldControlLogic(); //you are going to want to replace this!
  
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

//my example design
void scaffoldControlLogic()
{/*
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
    screenTransY+=inchesToPixels(.02f); */
}


void mousePressed()
{
    if (startTime == 0) //start time on the instant of the first user click
    {
      startTime = millis();
      println("time started!");
    } 
    if(overRotationCircle) { 
      rotationLocked = true; 
    } else {
      rotationLocked = false;
    }
    if(overScaleCircle) { 
      scaleLocked = true; 
    } else {
      scaleLocked = false;
    }
    
}

void mouseClicked() {
  if (mouseX > width/2-100 && mouseX < width/2+100 && mouseY >height-20 && mouseY < height)
  {  
    return;
  } else {
    Target t = targets.get(trialIndex);
    t.x = mouseX-width/2;
    t.y = mouseY-height/2;
  }
}

void mouseDragged() {
  if(rotationLocked) {
     Target t = targets.get(trialIndex);
      float x = width/2+t.x+screenTransX;
      float y = height/2+t.y+screenTransY;
      float tanValue = -(mouseX-x)/(mouseY-y);
      rotationOffset = degrees(atan(tanValue));
      if (mouseY > y) {
        rotationOffset += 180;
      }
     t.rotation = rotationOffset;
  }
  if(scaleLocked) {
    Target t = targets.get(trialIndex);
    scaleOffset = (mouseX-width/2-t.x-screenTransX) / sin(radians(t.rotation+45));
    t.z = scaleOffset / sqrt(2) * 2;
    t.z = max(t.z, 0);
  }
}
void mouseReleased()
{
  rotationLocked = false;
  scaleLocked = false;

  // check to see if user clicked to proceed
  if (mouseX > width/2-100 && mouseX < width/2+100 && mouseY >height-20 && mouseY < height)
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    //and move on to next trial
    trialIndex++;

    screenTransX = 0;
    screenTransY = 0;

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}


public boolean checkForSuccess()
{
	Target t = targets.get(trialIndex);	
	boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f); //has to be within .1"
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