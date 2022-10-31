import 'package:flutter/material.dart';

import 'styles.dart';
import '../game_internals/sudoku.dart';

MaterialColor emptyColor(bool gameOver) =>
    gameOver ? Styles.primaryColor : Styles.secondaryColor;

Color buttonColor(int k, int i) {
  Color color;
  if (([0, 1, 2].contains(k) && [3, 4, 5].contains(i)) ||
      ([3, 4, 5].contains(k) && [0, 1, 2, 6, 7, 8].contains(i)) ||
      ([6, 7, 8].contains(k) && [3, 4, 5].contains(i))) {
    if (Styles.primaryBackgroundColor == Styles.darkGrey) {
      color = Styles.grey;
    } else {
      color = Colors.grey[300]!;
    }
  } else {
    color = Styles.primaryBackgroundColor;
  }

  return color;
}

double buttonSize() {
  double size = 50;
  if (HomePageState.platform.contains('android') ||
      HomePageState.platform.contains('ios')) {
    size = 38;
  }
  return size;
}

double buttonFontSize() {
  double size = 20;
  if (HomePageState.platform.contains('android') ||
      HomePageState.platform.contains('ios')) {
    size = 16;
  }
  return size;
}

BorderRadiusGeometry buttonEdgeRadius(int k, int i, int rows) {

  BorderRadiusGeometry border = BorderRadius.circular(0);
  const double radius = 8.0;
  
  if (k == 0 && i == 0) {
    border = const BorderRadius.only(topLeft: Radius.circular(radius));
    if (rows == 1) {
      border = const BorderRadius.only(topLeft: Radius.circular(radius), bottomLeft: Radius.circular(radius));
    }  
  } else if (k == 0 && i == 8) {
    border = const BorderRadius.only(topRight: Radius.circular(radius));
    if (rows == 1) {
      border = const BorderRadius.only(topRight: Radius.circular(radius), bottomRight: Radius.circular(radius));
    }  
  } else if ((k == (rows - 1)) && i == 0) {
    border = const BorderRadius.only(bottomLeft: Radius.circular(radius));
    if (rows == 1) {
      border = const BorderRadius.only(bottomLeft: Radius.circular(radius), topLeft: Radius.circular(radius));
    }
  } else if (k == (rows - 1) && i == 8) {
    border = const BorderRadius.only(bottomRight: Radius.circular(radius));
    if (rows == 1) {
      border = const BorderRadius.only(bottomRight: Radius.circular(radius), topRight: Radius.circular(radius));
    }
  } 

  return border;
}
