String fileName;
String[] data;
String[] title;
String[] categories;
int[] numbers;
boolean[] selection;
float maxNum;
float barWidth = 0.0;
PFont f;
String chartTitle;
int fontSize = 1;
float maxHeightValue = 0.0;
int chartMode = 0;
float prevLineX = 0.0;
float prevLineY = 0.0;

//toggle transition
boolean barToLine = false;
boolean lineToBar = false;
boolean barToPie = false;
boolean pieToBar = false;
boolean lineToPie = false;
boolean pieToLine = false;
int animationFrames = 0;
float[] angles;
float[] heights;
float[] xPositions;
float[] yPositions;
float dataSum = 0.0;
float pieXs[];
float pieYs[];
//Colors for pie sections
color[] pieColors = {color(255, 8, 0), color(0, 255, 0), color(265, 165, 0), color(196, 0, 0), color(6, 79, 186), 
  color(255, 225, 53), color(255, 218, 185), color(255, 244, 79), color(242, 62, 63), color(50, 205, 50), color(255, 130, 67), color(221,160,221), 
  color(182,213,59), color(221, 246, 87),color(210,180,140)
};

void setup() {
  size(1000, 1000);
  if (surface != null) {
    surface.setResizable(true);
  }
  animationFrames = 0;
  chartMode = 0;
  background(255);
  rect(0.1*width, 0.1*height, 0.75*width, 0.75*height, 1);
  fileName = "data_a2.csv";
  data = loadStrings(fileName);
  title = split(data[0], ",");
  categories = new String[data.length-1];
  numbers = new int[data.length-1];
  selection = new boolean[data.length-1];
  maxNum = 0;
  for (int i = 1; i < data.length; i++) {
    String currentRow = data[i];
    String[] rowData = split(currentRow, ",");
    categories[i-1] = rowData[0];
    String rawNum = rowData[1];
    numbers[i-1] = parseInt(rawNum);
    dataSum += numbers[i-1];
    if (numbers[i-1] > maxNum) {
      maxNum = numbers[i-1];
    }
  }
  heights = new float[numbers.length];
  xPositions = new float[numbers.length];
  yPositions = new float[numbers.length];
  barWidth = (0.75*(float)width) / (2.0 * (data.length-1) + 1.0);
  angles = new float[numbers.length];
  for (int i = 0; i < numbers.length; i++) {
    float heightRatio = 0.8 *((float)numbers[i]) / maxNum;
    heights[i] = 0.75*height * heightRatio;
    xPositions[i] = (0.1 * width) + barWidth + (2.0 * i * barWidth);
    yPositions[i] = (0.1 * height) + (0.75*height * (1.0 - (heights[i] / (0.75*height))));
    maxHeightValue = max((float)numbers[i], maxHeightValue);
    float angle = 360.0 * numbers[i] / dataSum;
    angles[i] = angle;
  }
  f = createFont("Arial", 16, true);
}

//Make transition from bar to pie. Animation occurs through custom implementation of linear interpolation.
void barToPieTransition() {
  float circleDiam = max(0.4*width, 0.4*height);
  float r = circleDiam / 2.0;
  //animation changes depending on how much time has elapsed
  if (animationFrames <= 50) {
    float barWidthDifference = 1.0 - barWidth;
    float barWidthChange = barWidthDifference / 50.0;
    float currentWidth = barWidth + (animationFrames * barWidthChange);
    for (int i = 0; i < numbers.length; i++) {
      fill(0);

      rect(xPositions[i], yPositions[i], currentWidth, heights[i], 0);
    }
  }
  if (animationFrames > 50) {
    float lastAngle = 0;
    int numControlPoints = 100;
    for (int i = 0; i < numbers.length; i++) {
      float angle = angles[i];
      float barStartY = yPositions[i];
      float barEndY = yPositions[i] + heights[i];
      if ((height/2.2) + (r * sin(lastAngle)) < (height/2.2) + (r * sin(lastAngle+radians(angle)))) {
        barEndY = barStartY;
        barStartY += heights[i];
      }
      float barDifference = barEndY - barStartY;
      float currentFrame = animationFrames - 50;
      for (int j = 0; j < numControlPoints; j++) {
        float currentAngle =  lastAngle + ((float)j / (float)numControlPoints) * radians(angle);
        float interpolatedPieX =  0.1*width + 0.25*width + (r * cos(currentAngle));
        float interpolatedPieY = (height/2.2) + (r * sin(currentAngle));
        float interpolatedBarY = barStartY + ((float)j / (float)numControlPoints) * barDifference;
        float xDiff = interpolatedPieX - xPositions[i];
        float yDiff = interpolatedPieY - interpolatedBarY;
        float xPos = xPositions[i] + ((currentFrame / 100.0)*xDiff);
        float yPos = interpolatedBarY + ((currentFrame / 100.0)*yDiff);
        fill(0);
        ellipse(xPos, yPos, 1, 1);
      }
      lastAngle += radians(angle);
    }
  }
}

//Make transition from pie to bar
void pieToBarTransition() {
  float circleDiam = max(0.4*width, 0.4*height);
  float r = circleDiam / 2.0;
  //animation changes depending on how much time has elapsed
  if (animationFrames < 100) {
    float lastAngle = 0;
    int numControlPoints = 100;
    
    for (int i = 0; i < numbers.length; i++) {

      float angle = angles[i];
      float barStartY = yPositions[i];
      float barEndY = yPositions[i] + heights[i];
      if ((height/2.2) + (r * sin(lastAngle)) < (height/2.2) + (r * sin(lastAngle+radians(angle)))) {
        barEndY = barStartY;
        barStartY += heights[i];
      }
      float barDifference = barEndY - barStartY;
      for (int j = 0; j < numControlPoints; j++) {
        float currentAngle =  lastAngle + ((float)j / (float)numControlPoints) * radians(angle);
        float interpolatedPieX =  0.1*width + 0.25*width + (r * cos(currentAngle));
        float interpolatedPieY = (height/2.2) + (r * sin(currentAngle));
        float interpolatedBarY = barStartY + ((float)j / (float)numControlPoints) * barDifference;
        float xDiff = interpolatedPieX - xPositions[i];
        float yDiff = interpolatedPieY - interpolatedBarY;
        float xPos = xPositions[i] + (((100-animationFrames) / 100.0)*xDiff);
        float yPos = interpolatedBarY + (((100-animationFrames) / 100.0)*yDiff);
        fill(0);
        ellipse(xPos, yPos, 1, 1);
      }
      lastAngle += radians(angle);
    }
  }
  if (animationFrames >= 100) {
    float barWidthDifference = 1.0 - barWidth;
    float barWidthChange = barWidthDifference / 50.0;
    int currentFrame = 50 - (animationFrames - 100);
    float currentWidth = barWidth + (currentFrame * barWidthChange);
    for (int i = 0; i < numbers.length; i++) {
      fill(0);
      rect(xPositions[i], yPositions[i], currentWidth, heights[i], 0);
    }
  }
}

//Animation from line to pie
void lineToPieTransition() {
  fill(0);
  float scalePercent = ((width / 1000.0) + (height / 1000.0)) / 2.0;
  //animation changes depending on how much time has elapsed
  if (animationFrames < 60) {
    for (int i = 0; i < numbers.length; i++) {

      float xPos = xPositions[i];
      float yPos = yPositions[i];
      ellipse(xPos, yPos, scalePercent*8.0, scalePercent*8.0);
      if (i > 0) {
        float xIncr = (xPos - prevLineX) / 60.0;
        float yIncr = (yPos - prevLineY) / 60.0;
        line(prevLineX, prevLineY, prevLineX + xIncr * (60-animationFrames), prevLineY + yIncr * (60-animationFrames));
      }
      prevLineX = xPos;
      prevLineY = yPos;
    }
  }
  if (animationFrames > 60 && animationFrames <= 160) {
    float circleDiam = max(0.4*width, 0.4*height);
    float r = circleDiam / 2.0;
    int currentFrame = animationFrames - 60;
    float lastAngle = 0;
    for (int i = 0; i < numbers.length; i++) {
      float targetAngle = lastAngle + radians(angles[i]/2.0);
      float interpolatedPieX =  0.1*width + 0.25*width + (r * cos(targetAngle));
      float interpolatedPieY = (height/2.2) + (r * sin(targetAngle));
      float ptX = xPositions[i] + (((float)currentFrame / 100.0) * (interpolatedPieX - xPositions[i]));
      float ptY = yPositions[i] + (((float)currentFrame / 100.0) * (interpolatedPieY - yPositions[i]));
      ellipse(ptX, ptY, scalePercent*8.0, scalePercent*8.0);
      lastAngle += radians(angles[i]);
    }
  }
  if (animationFrames > 160) {
    float circleDiam = max(0.4*width, 0.4*height);
    float r = circleDiam / 2.0;
    float lastAngle = 0;
    for (int i = 0; i < numbers.length; i++) {
      float targetAngle = lastAngle + radians(angles[i]/2.0);
      float interpolatedPieX =  0.1*width + 0.25*width + (r * cos(targetAngle));
      float interpolatedPieY = (height/2.2) + (r * sin(targetAngle));
      ellipse(interpolatedPieX, interpolatedPieY, scalePercent*8.0, scalePercent*8.0);
      lastAngle += radians(angles[i]);
    }
  }
}

//Transition from pie to line
void pieToLineTransition() {
  fill(0);
  float scalePercent = ((width / 1000.0) + (height / 1000.0)) / 2.0;
  
  //animation changes depending on how much time has elapsed
  if (animationFrames < 40) {
    float circleDiam = max(0.4*width, 0.4*height);
    float r = circleDiam / 2.0;
    float lastAngle = 0;
    for (int i = 0; i < numbers.length; i++) {
      float targetAngle = lastAngle + radians(angles[i]/2.0);
      float interpolatedPieX =  0.1*width + 0.25*width + (r * cos(targetAngle));
      float interpolatedPieY = (height/2.2) + (r * sin(targetAngle));
      ellipse(interpolatedPieX, interpolatedPieY, scalePercent*8.0, scalePercent*8.0);
      lastAngle += radians(angles[i]);
    }
  }
  if (animationFrames >= 40 && animationFrames < 140) {
    float circleDiam = max(0.4*width, 0.4*height);
    float r = circleDiam / 2.0;
    int currentFrame = animationFrames - 40;
    float lastAngle = 0;
    for (int i = 0; i < numbers.length; i++) {
      float targetAngle = lastAngle + radians(angles[i]/2.0);
      float interpolatedPieX =  0.1*width + 0.25*width + (r * cos(targetAngle));
      float interpolatedPieY = (height/2.2) + (r * sin(targetAngle));
      float ptX = xPositions[i] + (((float)(100.0-currentFrame) / 100.0) * (interpolatedPieX - xPositions[i]));
      float ptY = yPositions[i] + (((float)(100.0-currentFrame) / 100.0) * (interpolatedPieY - yPositions[i]));
      ellipse(ptX, ptY, scalePercent*8.0, scalePercent*8.0);
      lastAngle += radians(angles[i]);
    }
  }
  if (animationFrames >= 140) {
    int currentFrame = animationFrames - 140;
    for (int i = 0; i < numbers.length; i++) { 
      float xPos = xPositions[i];
      float yPos = yPositions[i];
      ellipse(xPos, yPos, scalePercent*8.0, scalePercent*8.0);
      if (i > 0) {
        float xIncr = (xPos - prevLineX) / 60.0;
        float yIncr = (yPos - prevLineY) / 60.0;
        line(prevLineX, prevLineY, prevLineX + xIncr * currentFrame, prevLineY + yIncr * currentFrame);
      }
      prevLineX = xPos;
      prevLineY = yPos;
    }
  }
}

void mouseClicked() {
  //Invoke transition between chart types
  if (!lineToBar && !barToLine && !barToPie) {
    if (mouseX > 0.6*width && mouseX < 0.6*width+0.08*width && mouseY > 0.04 * height && mouseY < 0.08 * height) {
      if (chartMode == 1) {
        lineToBar = true;
      }
      if (chartMode == 2) {
        pieToBar = true;
      }
      chartMode = 0;
    }
    if (mouseX > 0.7*width && mouseX < 0.7*width+0.08*width && mouseY > 0.04 * height && mouseY < 0.08 * height) {
      if (chartMode == 0) {
        barToLine = true;
      }
      if (chartMode == 2) {
        pieToLine = true;
      }
      chartMode = 1;
    }
    if (mouseX > 0.8*width && mouseX < 0.8*width+0.08*width && mouseY > 0.04 * height && mouseY < 0.08 * height) {
      if (chartMode == 0) {
        barToPie = true;
      }
      if (chartMode == 1) {
        lineToPie = true;
      }
      chartMode = 2;
    }
  }
}

//Determine if mouse within pie
boolean mouseIntersectPie(float centerX, float centerY, float r, float lastAngle, float angle) {
  float dist = sqrt((centerX-mouseX)*(centerX-mouseX) + (centerY-mouseY)*(centerY-mouseY));
  if (dist < r) {
    double mouseAngle = atan2(mouseY - centerY, mouseX - centerX);
    if (mouseAngle < 0) {
      mouseAngle += (2.0 *PI);
    }
    if (mouseAngle <= lastAngle + radians(angle) && mouseAngle > lastAngle) {
      return true;
    }
    return false;
  }
  return false;
}

//draw pie chart
void pieChart() {
  float lastAngle = 0;
  float circleDiam = max(0.4*width, 0.4*height);
  float r = circleDiam / 2.0;
  fill(0);
  rect(0.1*width + 0.25 * width + (circleDiam / 1.3), (height / 4.5), 0.1*width, ((width / (3.0*numbers.length)) * (numbers.length+1)));
  for (int i = 0; i < numbers.length; i++) {
    fill(pieColors[i % pieColors.length]);

    float angle = angles[i];
    arc(0.1*width + 0.25*width, height/2.2, circleDiam, circleDiam, lastAngle, lastAngle+radians(angle));
    lastAngle += radians(angle);
  }
  lastAngle = 0;
  for (int i = 0; i < numbers.length; i++) {
    float angle = angles[i];
    String percent = String.valueOf(100*numbers[i] / dataSum);
    String truncatedPercent = "";
    for (int k = 0; k < min(4, percent.length()); k++) {
      truncatedPercent += percent.charAt(k);
    }
    percent = truncatedPercent;
    percent += "%";
    fill(0);

    pushMatrix();
    float adjustedR = 0.8*r;
    if (lastAngle + radians(angle/2.0) > PI / 2.0 && lastAngle + radians(angle/2.0) < 3.0*PI / 2.0) {
      adjustedR = 0.85*r;
    }
    float x = 0.1*width + 0.25*width + (adjustedR * cos(lastAngle+radians(angle/2.0)));
    if (lastAngle + radians(angle/2.0) > PI / 2.0 && lastAngle + radians(angle/2.0) < 3.0*PI / 2.0) {
      x -= 0.02*width;
    }
    float y = (height/2.2) + (adjustedR * sin(lastAngle+radians(angle/2.0)));
    if (lastAngle + radians(angle/2.0) > 0 && lastAngle + radians(angle/2.0) < PI / 2.0) {
      y += 0.02*height;
    }
    if (lastAngle + radians(angle/2.0) > PI / 4.0 && lastAngle + radians(angle/2.0) < PI / 2.0) {
      x -= 0.02*width;
    }
    float centerX = 0.1*width + 0.25*width; 
    float centerY = height/2.2;
    if (mouseIntersectPie(centerX, centerY, r, lastAngle, angle)) {
      selection[i] = true;
      fill(pieColors[i % pieColors.length]);
      arc(0.1*width + 0.25*width, height/2.2, circleDiam*1.1, circleDiam*1.1, lastAngle, lastAngle+radians(angle));

      int labelTextSize = (int) (1.2 * fontSize);
      textFont(f, labelTextSize);
      percent = "("+percent+","+numbers[i]+")";
      if (angle > 12) {
        fill(50);
        text(percent, 0.1*width + 0.25*width + (0.9 * r * cos(lastAngle+radians(angle/2.0))), (height/2.2) + (0.9*r * sin(lastAngle+radians(angle/2.0))), 0.1*width, 0.05*height);
      } else {
        if (x > centerX) {
          fill(0);
          text(percent, 0.1*width + 0.25*width + (1.1 * r * cos(lastAngle+radians(angle/2.0))), (height/2.2) + (1.1*r * sin(lastAngle+radians(angle/2.0))), 0.1*width, 0.05*height);
        } else {
          fill(0);
          text(percent, 0.1*width + 0.25*width + (1.25 * r * cos(lastAngle+radians(angle/2.0))), (height/2.2) + (1.25*r * sin(lastAngle+radians(angle/2.0))), 0.1*width, 0.05*height);
        }
      }
      textFont(f, fontSize);
    } else {
      selection[i] = false;
      if (angle > 12) {

        text(percent, x, y, 0);
      }
    }
    fill(0);
    popMatrix();

    fill(pieColors[i % pieColors.length]);
    if (selection[i]) {
      textFont(f, 1.3*fontSize);
      fill(255);
    } else {
      textFont(f, fontSize);
    }
    text(categories[i], 0.1*width + 0.25 * width + (circleDiam / 1.25), (height / 4.0) + ((width / (3.0*numbers.length)) * i));
    textFont(f, fontSize);
    lastAngle += radians(angle);
  }
}

//Animated transition from bar to line
void barToLineTransition(float xPos, float yPos, float barHeight, float barIncr, float barWidthIncr, float scalePercent, int i) {
  fill(0);
  //animation changes depending on how much time has elapsed
  if (animationFrames < 56) {
    rect(xPos, yPos, barWidth, barHeight - (barIncr * animationFrames), 0);
  }
  if (animationFrames >= 56 && animationFrames < 96) {
    rect(xPos, yPos, barWidth - ((animationFrames - 56) * barWidthIncr), 8.0*scalePercent, 0);
  }
  if (animationFrames >= 96 && animationFrames < 156) {
    ellipse(xPos, yPos, scalePercent*8.0, scalePercent*8.0);
    if (i > 0) {
      float xIncr = (xPos - prevLineX) / 60.0;
      float yIncr = (yPos - prevLineY) / 60.0;
      line(prevLineX, prevLineY, prevLineX + xIncr * (animationFrames - 96), prevLineY + yIncr * (animationFrames - 96));
    }
    prevLineX = xPos;
    prevLineY = yPos;
  }
}

//Animated transition from line to bar
void lineToBarTransition(float xPos, float yPos, float scalePercent, int i, float barWidthIncr, float barHeight, float barIncr) {
  fill(0);
  //animation changes depending on how much time has elapsed
  if (animationFrames < 56) {
    ellipse(xPos, yPos, scalePercent*8.0, scalePercent*8.0);
    if (i > 0) {
      float xIncr = (xPos - prevLineX) / 60.0;
      float yIncr = (yPos - prevLineY) / 60.0;
      line(prevLineX, prevLineY, prevLineX + xIncr * (60-animationFrames), prevLineY + yIncr * (60-animationFrames));
    }
    prevLineX = xPos;
    prevLineY = yPos;
  }
  if (animationFrames >= 56 && animationFrames < 96) {
    rect(xPos, yPos, barWidth - ((40-(animationFrames - 56)) * barWidthIncr), 8.0*scalePercent, 0);
  }
  if (animationFrames >= 96 && animationFrames < 156) {
    rect(xPos, yPos, barWidth, barHeight - (barIncr * (60-(animationFrames-96))), 0);
  }
}

//Draw line graph
void lineGraph(float xPos, float yPos, float scalePercent, int i) {
  if ((mouseX-xPos)*(mouseX-xPos) + (mouseY-yPos)*(mouseY-yPos) < (8.0 * scalePercent)*(8.0 * scalePercent)) {
    fill(color(0, 0, 225));
    selection[i] = true;
  } else {
    fill(color(0));
    selection[i] = false;
  }
  ellipse(xPos, yPos, scalePercent*8.0, scalePercent*8.0);
  if (i > 0) {
    line(prevLineX, prevLineY, xPos, yPos);
  }
  prevLineX = xPos;
  prevLineY = yPos;
}

//Draw bar graph
void barChart(float xPos, float yPos, float barHeight, int i) {
  if (mouseX > xPos && mouseX < xPos + barWidth && mouseY > yPos && mouseY < yPos + barHeight) {
    fill(color(255, 255, 0));
    rect(xPos, yPos, barWidth, barHeight, 0);
    selection[i] = true;
  } else {
    fill(0);
    selection[i] = false;
    rect(xPos, yPos, barWidth, barHeight, 0);
  }
}

//Controls animation frames: called continuously in draw()
void toggleAnimationPhase() {
  if (animationFrames >= 155) {
    if (barToLine) {
      barToLine = false;
      animationFrames = 0;
    }
    if (lineToBar) {
      lineToBar = false;
      animationFrames = 0;
    }
  } else {
    if (barToLine && !lineToBar) {
      animationFrames += 1;
    }
    if (lineToBar && !barToLine) {
      animationFrames += 1;
    }
  }
  if (animationFrames  >= 150) {
    if (barToPie) {
      barToPie = false;
      animationFrames = 0;
    }
  } else {
    if (barToPie) {
      animationFrames += 1;
    }
  }
  if (animationFrames  >= 150) {
    if (pieToBar) {
      pieToBar = false;
      animationFrames = 0;
    }
  } else {
    if (pieToBar) {
      animationFrames += 1;
    }
  }
  if (animationFrames  >= 200) {
    if (lineToPie) {
      lineToPie = false;
      animationFrames = 0;
    }
    if (pieToLine) {
      pieToLine = false;
      animationFrames = 0;
    }
  } else {
    if (lineToPie) {
      animationFrames += 1;
    }
    if (pieToLine) {
      animationFrames += 1;
    }
  } 
}

void draw() {
  clear();
  background(255);
  if (surface != null) {
    surface.setResizable(true);
  }
  //Scale font size according to canvas size
  float fontPercent = ((width / 1000.0) + (height / 1000.0)) / 2.0;
  float textSize = fontPercent * 16.0;
  if (textSize >= 1.0) {
    fontSize = (int)textSize;
  }
  textFont(f, fontSize);
  fill(0);
  String chartTitle = "DanZ Chart: " + title[0] + " measured by " + title[1];
  text(chartTitle, 0.3 * width, 0.05 * height);
  if (chartMode != 2) {
    pushMatrix();
    translate(0.03 * width, 0.5 * height);
    rotate(3.0 * PI / 2.0);
    text(title[1], 0.0, 0.0);
    popMatrix();
    text(title[0], 0.4 * width, 0.1 * height + (0.75 * height) + (0.08 * height));
  }
  fill(255);
  
  //Scale chart according to window size
  rect(0.1*width, 0.1*height, 0.75*width, 0.75*height, 1);
  
  //Hovering over bar chart button
  if (mouseX > 0.6*width && mouseX < 0.6*width+0.08*width && mouseY > 0.04 * height && mouseY < 0.08 * height) {
    fill(color(100, 100, 100));
  } else {
    if (chartMode == 0) {
      fill(color(0));
    } else {
      fill(color(0, 150, 0));
    }
  }
  rect(0.6*width, 0.04*height, 0.08*width, 0.04*height, 1);
  fill(255);
  text("Bar chart", 0.61*width, 0.06*height);
  toggleAnimationPhase();
  
  //Hovering over line chart button
  if (mouseX > 0.7*width && mouseX < 0.7*width+0.08*width && mouseY > 0.04 * height && mouseY < 0.08 * height) {
    fill(color(100, 100, 100));
  } else {
    if (chartMode == 1 && !barToLine) {
      fill(color(0));
    } else {
      fill(color(255, 165, 0));
    }
  }
  rect(0.7*width, 0.04*height, 0.08*width, 0.04*height, 1);
  
  //Hovering over pie chart button
  fill(255);
  text("Line chart", 0.71*width, 0.06*height);
  if (mouseX > 0.8*width && mouseX < 0.8*width+0.08*width && mouseY > 0.04 * height && mouseY < 0.08 * height) {
    fill(color(100, 100, 100));
  } else {
    if (chartMode == 2) {
      fill(color(0));
    } else {
      fill(color(128, 0, 128));
    }
  }
  rect(0.8*width, 0.04*height, 0.08*width, 0.04*height, 1);
  fill(255);
  text("Pie chart", 0.81*width, 0.06*height);
  fill(0);
  
  //Test if transitioning
  if (barToPie) {
    barToPieTransition();
  }
  if (pieToBar) {
    pieToBarTransition();
  }
  if (lineToPie) {
    lineToPieTransition();
  }
  if (pieToLine) {
    pieToLineTransition();
  }
  //Only draw horizontal grid lines if not pie chart or transitioning to/from pie chart
  if (chartMode != 2 && !pieToBar && !pieToLine) {
    for (int i = 0; i < 5; i++) {
      float currentVal = ((4.0-i)/4.0) * maxHeightValue;
      float xPos = 0.04 * width;
      float yPos = (0.1 * height) + ((i/4.0) * 0.75 * height);
      text(currentVal, xPos, 1.01*yPos);
      line(0.1*width, yPos, (0.1*width + (0.75*width)), yPos);
    }
    //Dont draw charts while transitioning between them
    if (!barToPie && !pieToBar) {
      barWidth = (0.75*(float)width) / (2.0 * (data.length-1) + 1.0);
      int labelTextSize = (int) (0.8 * fontSize);
      textFont(f, labelTextSize);
      float scalePercent = ((width / 1000.0) + (height / 1000.0)) / 2.0;
      float widthDotDiff = barWidth - (8.0 * scalePercent);
      float barWidthIncr = widthDotDiff / 40.0;
      //Iterate through data points to draw either bar chart or line chart
      for (int i = 0; i < numbers.length; i++) {
        float barHeight = heights[i];
        float barIncr = barHeight / 56.0;
        xPositions[i] = (0.1 * width) + barWidth + (2.0 * i * barWidth);
        yPositions[i] = (0.1 * height) + (0.75*height * (1.0 - (barHeight / (0.75*height))));
        float xPos = xPositions[i];
        float yPos = yPositions[i];
        if (barToLine && !lineToBar) {
          barToLineTransition(xPos, yPos, barHeight, barIncr, barWidthIncr, scalePercent, i);
        }
        if (lineToBar && !barToLine) {
          lineToBarTransition(xPos, yPos, scalePercent, i, barWidthIncr, barHeight, barIncr);
        }
        if (chartMode == 0 && lineToBar == false) {
          barChart(xPos, yPos, barHeight, i);
        }
        if (chartMode == 1 && !barToLine && !lineToPie && !pieToLine) {
          lineGraph(xPos, yPos, scalePercent, i);
        }
        for (int j = 0; j < selection.length; j++) {
          if (selection[j] == true) {
            fill(color(255, 0, 0));
            textFont(f, 1.5*labelTextSize);
            text("("+categories[j]+","+numbers[j]+")", mouseX, mouseY, 1000);
          }
        }
        //Draw labels on x axis
        textFont(f, labelTextSize);
        fill(0);
        pushMatrix();
        translate(xPos, 0.1 * height + (0.75 * height) + (0.02 * height));
        rotate(PI/4.0);
        text(categories[i], 0.0, 0.0);
        popMatrix();
      }
    }
  } else {
    //Only draw the actual pie chart if not transitioning to/from pie chart
    if (!barToPie && !pieToBar && !lineToPie && !pieToLine) {
      pieChart();
    }
  }
}