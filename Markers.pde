public class Marker{
  public int score = 0, index;
  private int x, y, w, h;
  
  public Marker(int x, int y, int w, int h, int index, int score){
    this.index = index;
    this.score = score;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  public boolean colliding(Car car){
    if(car.pos.x > x - w / 2 && car.pos.x < x + w / 2 && car.pos.y > y - h / 2 && car.pos.y < y + h / 2){
      return true;
    }
    return false;
  }

  public void renderMarker(){
    rectMode(CENTER);
    stroke(255, 0, 0);
    noFill();
    rect(x, y, w, h);
  }
}
