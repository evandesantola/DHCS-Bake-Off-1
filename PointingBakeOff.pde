import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;

//when in doubt, consult the Processsing reference: https://processing.org/reference/

int margin = 200; //set the margin around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
Robot robot; //initalized in setup 
int buttonRegion = -1;
int numRepeats = 1; //sets the number of times each button repeats in the test
int mouseXPrev = width/2;
int mouseYPrev = height/2;

void setup()
{
  size(700, 700); // set the size of the window
  //noCursor(); //hides the system cursor if you want
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  //rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects

  try {
    robot = new Robot(); //create a "Java Robot" class that can move the system cursor
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
    // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  System.out.println("trial order: " + trials);
  robot.mouseMove(width/2, (height)/2); //on click, move cursor to roughly center of window!

  frame.setLocation(0, 0); // put window in top left corner of screen (doesn't always work)
}


void draw()
{
  background(0); //set background to black

  if (trialNum >= trials.size()) //check to see if test is over
  {
    float timeTaken = (finishTime-startTime) / 1000f;
    float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f), 0, 100);
    fill(255); //set fill color to white
    //write to screen (not console)
    text("Finished!", width / 2, height / 2); 
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 2 + 60);
    text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
    text("Average time for each button: " + nf((timeTaken)/(float)(hits+misses), 0, 3) + " sec", width / 2, height / 2 + 100);
    text("Average time for each button + penalty: " + nf(((timeTaken)/(float)(hits+misses) + penalty), 0, 3) + " sec", width / 2, height / 2 + 140);
    return; //return, nothing else to do now test is over
  }

  fill(255); //set fill color to white
  text((trialNum + 1) + " of " + trials.size(), 40, 20); //display what trial the user is on

  for (int i = 0; i < 16; i++)// for all button
    drawButton(i); //draw button

  fill(255, 0, 0, 200); // set fill color to translucent red
  ellipse(mouseX, mouseY, 20, 20); //draw user cursor as a circle with a diameter of 20
}

void mousePressed() // test to see if hit was in target!
{
  // validation moved to mouseMoved and keyPressed
}  

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
  int x = (i % 4) * (padding + buttonSize) + margin;
  int y = (i / 4) * (padding + buttonSize) + margin;
  return new Rectangle(x, y, buttonSize, buttonSize);
}

/*
Regions are:

1 1 2 2
1 1 2 2
3 3 4 4
3 3 4 4
*/
int getCorrectButtonRegion(int i) //for a given button ID, what is its location and size
{
  if ((i%4) < 2) {
     if (i < 8) {
       return 1;
     } else {
        return 3; 
     }
  } else {
        if (i < 8) {
       return 2;
     } else {
        return 4; 
     } 
  }
}

int getRow(int i) {
   return i/4; 
}
int getCol(int i) {
   return i%4; 
}

/*
Directions are:
0   1
2   3
*/
int getCorrectButtonDirection(int i) //for a given button ID, what is its location and size
{
  return int(2*(getRow(i)%2)) + getCol(i)%2;
}

//you can edit this method to change how buttons appear
void drawButton(int i)
{
  Rectangle bounds = getButtonLocation(i);

  if (trials.get(trialNum) == i) // see if current button is the target
    fill(0, 255, 255); // if so, fill cyan
  else
    fill(200); // if not, fill gray

  rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
}

/*
0  1
2  3
*/
int headingToDirection(float heading) {
  if (heading > 0 && heading <= 90) {
    return 0;
  } else if (heading > 90 && heading <=180) {
    return 1;
  } else if (heading < 0 && heading > -90) {
    return 2;
  } else {
    return 3;
  }
}

void handleCheck() {
  PVector origin = new PVector(0, 0);
  PVector posDelta = new PVector(mouseXPrev-mouseX, mouseYPrev-mouseY);
  float a = PVector.angleBetween(origin, posDelta);
  
  // only register if change is significant enough to be magnitude greater than 100.  that number is a magic number governing the amount of mouse movement.  I chose 100 but you can fiddle around with it
  if ((posDelta.mag() > 100) && buttonRegion != -1) {  
    if (trialNum >= trials.size()) //if task is over, just return
      return;
    if (trialNum == 0) //check if first click, if so, start timer
      startTime = millis();
  
    if (trialNum == trials.size() - 1) //check if final click
    {
      finishTime = millis();
      //write to terminal some output. Useful for debugging too.
      println("we're done!");
    }
  
    int correctRegion = getCorrectButtonRegion(trials.get(trialNum));
    int correctDirection = getCorrectButtonDirection(trials.get(trialNum));

    println("PosDelta", posDelta);
    float heading = degrees(posDelta.heading());
    println("heading", heading);
    println("Heading converted to quadrant:", headingToDirection(heading));
    println("Degrees", degrees(a));  // Prints "10.304827"
    println("Magnitude is", posDelta.mag());
    println("Region registered", buttonRegion);
    println("Correct region", correctRegion);

    int direction = headingToDirection(heading);
    println("Direction registered", direction);
    println("Correct direction", correctDirection);
    //check to see if mouse cursor is inside button 
    if (direction == correctDirection && buttonRegion == correctRegion)
    {
      System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
      hits++; 
    } else
    {
      System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
      misses++;
    }
    mouseXPrev = width/2;
    mouseYPrev = (height)/2;
    trialNum++; //Increment trial number
    buttonRegion = -1;
    robot.mouseMove(width/2, (height)/2); //on click, move cursor to roughly center of window!
  }
}
void mouseMoved()
{
  handleCheck();

  //can do stuff everytime the mouse is moved (i.e., not clicked)
  //https://processing.org/reference/mouseMoved_.html
}

void mouseDragged()
{
  //can do stuff everytime the mouse is dragged
  //https://processing.org/reference/mouseDragged_.html
}

void keyPressed() 
{
  if (key == '1') {
    buttonRegion = 1;
  } else if (key == '2') {
    buttonRegion = 2;
  } else if (key == '3') {
    buttonRegion = 3;
  } else if (key == '4') {
    buttonRegion = 4;
  }
  
  
    handleCheck();

  //can use the keyboard if you wish
  //https://processing.org/reference/keyTyped_.html
  //https://processing.org/reference/keyCode.html
}
