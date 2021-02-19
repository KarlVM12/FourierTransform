import java.util.Arrays;

float[] drawX;
float[] drawY;
int skip = 5;
float[][] yFourier;
float[][] xFourier;


void setup()
{
 size(1000,800);
 
 loadDrawing("cat.json");
 //loadMarieHeart();
 yFourier = dft(drawY);
 xFourier = dft(drawX);
 sortFouriers();
 
}

float time = 0;
ArrayList<Float> wave = new ArrayList<Float>();
ArrayList<Float> xwave = new ArrayList<Float>();

void draw()
{
  background(255);
  translate(width/2, height/2);
  
  //translate(-200,0);  
  float[] xXY = fourierSeries(0, -300, HALF_PI, xFourier, 1);
  float[] yXY = fourierSeries(-200, 0, HALF_PI, yFourier, 0);

  
   // Adding points to the wave arraylist and drawing the wave with points
  //push();
  translate(300,0);
  wave.add(yXY[1]);
  xwave.add(xXY[1]);
  
  // drawing wave
  for (int i = 0; i < wave.size(); i++)
  {
    ellipse(xwave.get((xwave.size()-1)-i),wave.get((wave.size()-1)-i),1,1);
  }
  
  // line to draw wave
  line(yXY[0]-300, yXY[1],xXY[1],yXY[1]); // y line
  line(xXY[1], yXY[0]-100,xXY[1],yXY[1]); // x line
  
  
  // clears the data from wave once it gets too big
  if (wave.size() == 1000)
    wave.remove(0);

  
  float dt = TWO_PI/yFourier.length;
  time += dt;
}



float[] fourierSeries(float x, float y, float rotation,float[][] fourier, int variable)
{
  float[] xy = new float[2];
  float prevx = 0, prevy = 0;
    float xX = 0, yY = 0;
   for(int i = 0; i < fourier.length; i++)
  {
    prevx = x;
    prevy = y;
    
    float freq = fourier[i][2];
    float radius = fourier[i][3];
    float phase = fourier[i][4];
   
    x += radius * cos((freq * time) + phase + rotation); 
    y += radius * sin((freq * time) + phase + rotation); 
   
    
    //if x values
    if (variable == 1)
    {
      prevx = xX;
      prevy = yY;
      
      push();
      xX += ( radius * cos((freq * time) + phase));
      yY += ( radius * sin((freq * time) + phase));
      
      translate(0, -300);
      noFill();
      stroke(0, 50);
      ellipse(prevx,prevy,radius*2,radius*2);
      
      //point and line
      stroke(0,50);
      ellipse(xX,yY,4,4);
      fill(0);
      stroke(0,100);
      line(prevx,prevy,xX,yY);
      pop();  
    }
    else // if y values
    {
      // circle of tracing path of line and point
      noFill();
      stroke(0, 50);
      ellipse(prevx,prevy,radius*2,radius*2);
    
      //point and line
      stroke(0,50);
      ellipse(x,y,4,4);
      fill(0);
      stroke(0,100);
      line(prevx,prevy,x,y);
    }  
} 
  
  xy[0] = x;
  xy[1] = y;
  return xy;
  
}



float[][] dft(float[] x)
{
  float N = x.length;
  float[][] X = new float [(int)N][5];
  float freq, amp, phase;
  
  for(int k = 0; k < N; k++)
  {
    float re = 0, im = 0;
    
    for(int n = 0; n < N; n++)
    {  
      float phi = (TWO_PI * k * n) / N;
      re += x[n] * cos(phi); 
      im -= x[n] * sin(phi);
      
    }
    re = re / N; // average of sum
    im = im / N; // average of sum
    freq = k; 
    amp = sqrt(re * re + im * im);
    phase = atan2(im, re);
    
    X[k][0] = re;
    X[k][1] = im;
    X[k][2] = freq;
    X[k][3] = amp;
    X[k][4] = phase;
  } 
  
  return X;  
}



void sortFouriers()
{
 java.util.Arrays.sort(xFourier, new java.util.Comparator<float[]>() {
    public int compare(float[] a, float[] b) {
        return Float.compare(b[0], a[0]);
    }
});
 java.util.Arrays.sort(yFourier, new java.util.Comparator<float[]>() {
    public int compare(float[] a, float[] b) {
        return Float.compare(b[0], a[0]);
    }
}); 
  
}



void loadDrawing(String filename) {
  JSONArray drawing = loadJSONObject(filename).getJSONArray("drawing");
  drawX = new float[drawing.size()/skip];
  drawY = new float[drawing.size()/skip];

  for (int i = 0; i < drawing.size()/skip; i+= 1) {
    drawX[i] = drawing.getJSONObject(i*skip).getFloat("x");
    drawY[i] = drawing.getJSONObject(i*skip).getFloat("y");
  }
}
