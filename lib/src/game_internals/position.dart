class Position {
  int _x;
  int _y;

  int get x => _x;
  int get y => _y;

  set x(int newVal) {
    _x = newVal;
  }

  set y(int newVal) {
    _y = newVal;
  }

  Position(this._x,this._y);
}