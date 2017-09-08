import processing.serial.*;

Serial myPort;
PrintWriter motion, radar;
int jarak_grid = 60;

int counter;
int t, sudut, jarak1, jarak2;
FloatList  X1 = new FloatList (), Y1 = new FloatList (), X2 = new FloatList (), Y2 = new FloatList ();
float shi, x_d, y_d, x, y;

void setup() 
{
  size(600, 600);
  background(102);
  myPort = new Serial(this, "COM9", 38400);
  myPort.bufferUntil('n');
  
  motion = createWriter("motion.dat");
  radar = createWriter("radar.dat");
  
  translate(width/2+X, height/2-Y);
  grid();
  robot(0,0,0);
}

void draw()
{ 
  kordinat__mouse();
  translate(width/2+X, height/2-Y);
  if (mousePressed) 
  {
    X1.clear();
    Y1.clear();
    X2.clear();
    Y2.clear();
    grid();
    robot((int)x/10,(int)y/10,shi/180*PI);
  }
  
  if ( myPort.available() > 0) 
  { 
    if(myPort.read()==0xf5){
      while(myPort.available() < 16){print();}//suka ngadat klo gak print
      int temp1,temp2;
      t = myPort.read();
      
      temp1 = myPort.read();
      temp2 = myPort.read()<<8;
      shi = (temp1 + temp2)/50.0;
      
      temp1 = myPort.read();
      temp2 = myPort.read()<<8;
      x = temp1 + temp2;
      
      temp1 = myPort.read();
      temp2 = myPort.read()<<8;
      x_d = temp1 + temp2;
      
      temp1 = myPort.read();
      temp2 = myPort.read()<<8;
      y = temp1 + temp2;
      
      temp1 = myPort.read();
      temp2 = myPort.read()<<8;
      y_d = temp1 + temp2;
      
      sudut = myPort.read();
      
      temp1 = myPort.read();
      temp2 = myPort.read()<<8;
      jarak1 = temp1 + temp2;
      
      temp1 = myPort.read();
      temp2 = myPort.read()<<8;
      jarak2 = temp1 + temp2;
      
      if(t%4==2)
      {
        float mm1 = jarak1*0.17+50;
        float mm2 = jarak2*0.17+50;
        
        X1.append((mm1*cos((sudut+shi)/180*PI)+x)/10);
        Y1.append((mm1*sin((sudut+shi)/180*PI)+y)/10);
        
        X2.append((mm2*cos((180+sudut+shi)/180*PI)+x)/10);
        Y2.append((mm2*sin((180+sudut+shi)/180*PI)+y)/10);
        
        println("sudut", sudut, "jarak1", mm1, "jarak2", mm2, X1.get(X1.size()-1), Y1.get(Y1.size()-1));
        
        radar.print(String.format("%.3f, %.3f, %.3f, %.3f%n", X1.get(X1.size()-1), Y1.get(Y1.size()-1), X2.get(X2.size()-1), Y2.get(Y2.size()-1)));
        radar.flush();
      }
      
      println("t", t, "shi", shi, "x", x, "x_d", x_d, "y", y, "y_d", y_d, "sudut");
      motion.print(String.format("%d, %.3f, %.3f, %.3f, %.3f, %.3f%n", t+100*counter, shi, x/1000, x_d/1000, y/1000, y_d/1000));
      motion.flush();
      
      grid();
      robot((int)x/10,(int)y/10,shi/180*PI);
      titik();
      
      if(t==100) counter++;
      
    }
    
  }
}

void titik()
{
  for(int a=0;a<X1.size();a++)
  {
    line(X1.get(a)+3,-Y1.get(a)+3,X1.get(a)-3,-Y1.get(a)-3);
    line(X1.get(a)-3,-Y1.get(a)+3,X1.get(a)+3,-Y1.get(a)-3);
    
    line(X2.get(a)+3,-Y2.get(a)+3,X2.get(a)-3,-Y2.get(a)-3);
    line(X2.get(a)-3,-Y2.get(a)+3,X2.get(a)+3,-Y2.get(a)-3);
  }
}

void keyPressed() {
  if (key == CODED) {
    myPort.write(keyCode);
    println(keyCode);
  }
  else myPort.write(key); 
}

void grid()
{
  background(102);
  fill(255,255,255);
  ellipse(0,0,10,10);
  
  fill(0);
  line(0,-height/2,0,height/2);
  line(-width/2,0,width/2,0);
  
  for(int a=jarak_grid;a<width/2;a+=jarak_grid)
  {
    line(a,-height/2,a,height);
    line(-a,-height/2,-a,height);
  }
  
  for(int a=jarak_grid;a<height/2;a+=jarak_grid)
  {
    line(-width/2,a,width/2,a);
    line(-width/2,-a,width/2,-a);
  }
}

void kordinat__mouse()
{
  fill(255,255,255);
  rect(0, 0, 90, 20);
  fill(0);
  int X = mouseX-width/2;
  int Y = height/2-mouseY;
  text( "x: " + X + " y: " + Y, 10, 15 );  
}

void robot(int X,int Y,float SHI)
{
  translate(X, -Y);
  fill(255,0,0);
  rotate(-SHI);
  rect(0,-8,20,16);
  rotate(SHI);
  translate(-X, Y);
}