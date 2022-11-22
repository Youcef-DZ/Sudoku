// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Uncomment the following lines when enabling Firebase Crashlytics
// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

import 'dart:async';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

import '../../alerts/all.dart';
import '../style/styles.dart';
import '../style/button_style.dart';
import 'position.dart';
import 'splash_screen_page.dart';

class Sudoku extends StatelessWidget {
  const Sudoku({Key? key}) : super(key: key);

  static const String versionNumber = '0.0.1';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Styles.primaryColor,
      ),
      home: const SplashScreenPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool firstRun = true;
  bool gameOver = false;
  bool isFABDisabled = false;
  late int selectedKey;
  late Position selectedCell;
  late List<List<List<int>>> gameList;
  late List<List<int>> game;
  late List<List<int>> gameSolved;
  static String? currentDifficultyLevel;
  static String? currentTheme;
  static String? currentAccentColor;

  static String platform = () {
    if (kIsWeb) {
      return 'web-${defaultTargetPlatform.toString().replaceFirst("TargetPlatform.", "").toLowerCase()}';
    } else {
      return defaultTargetPlatform
          .toString()
          .replaceFirst("TargetPlatform.", "")
          .toLowerCase();
    }
  }();
  static bool isDesktop = ['windows', 'linux', 'macos'].contains(platform);

  @override
  void initState() {
    super.initState();
    try {
      doWhenWindowReady(() {
        appWindow.alignment = Alignment.center;
        appWindow.minSize = const Size(625, 625);
      });
      // ignore: empty_catches
    } on UnimplementedError {}
    getPrefs().whenComplete(() {
      if (currentDifficultyLevel == null) {
        currentDifficultyLevel = 'easy';
        setPrefs('currentDifficultyLevel');
      }
      if (currentTheme == null) {
        if (MediaQuery.maybeOf(context)?.platformBrightness != null) {
          currentTheme =
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? 'light'
                  : 'dark';
        } else {
          currentTheme = 'dark';
        }
        setPrefs('currentTheme');
      }
      if (currentAccentColor == null) {
        currentAccentColor = 'Blue';
        setPrefs('currentAccentColor');
      }
      _newGame(currentDifficultyLevel!);
      _changeTheme('set');
      _changeAccentColor(currentAccentColor!, true);
    });
  }

  Future<void> getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentDifficultyLevel = prefs.getString('currentDifficultyLevel');
      currentTheme = prefs.getString('currentTheme');
      currentAccentColor = prefs.getString('currentAccentColor');
    });
  }

  setPrefs(String property) async {
    final prefs = await SharedPreferences.getInstance();
    if (property == 'currentDifficultyLevel') {
      prefs.setString('currentDifficultyLevel', currentDifficultyLevel!);
    } else if (property == 'currentTheme') {
      prefs.setString('currentTheme', currentTheme!);
    } else if (property == 'currentAccentColor') {
      prefs.setString('currentAccentColor', currentAccentColor!);
    }
  }

  void _changeTheme(String mode) {
    setState(() {
      if (currentTheme == 'light') {
        if (mode == 'switch') {
          Styles.primaryBackgroundColor = Styles.darkGrey;
          Styles.secondaryBackgroundColor = Styles.grey;
          Styles.foregroundColor = Styles.white;
          currentTheme = 'dark';
        } else if (mode == 'set') {
          Styles.primaryBackgroundColor = Styles.white;
          Styles.secondaryBackgroundColor = Styles.white;
          Styles.foregroundColor = Styles.darkGrey;
        }
      } else if (currentTheme == 'dark') {
        if (mode == 'switch') {
          Styles.primaryBackgroundColor = Styles.white;
          Styles.secondaryBackgroundColor = Styles.white;
          Styles.foregroundColor = Styles.darkGrey;
          currentTheme = 'light';
        } else if (mode == 'set') {
          Styles.primaryBackgroundColor = Styles.darkGrey;
          Styles.secondaryBackgroundColor = Styles.grey;
          Styles.foregroundColor = Styles.white;
        }
      }
      setPrefs('currentTheme');
    });
  }

  void _changeAccentColor(String color, [bool firstRun = false]) {
    setState(() {
      if (Styles.accentColors.keys.contains(color)) {
        Styles.primaryColor = Styles.accentColors[color]!;
      } else {
        currentAccentColor = 'Blue';
        Styles.primaryColor = Styles.accentColors[color]!;
      }
      if (color == 'Red') {
        Styles.secondaryColor = Styles.orange;
      } else {
        Styles.secondaryColor = Styles.lightRed;
      }
      if (!firstRun) {
        setPrefs('currentAccentColor');
      }
    });
  }

  void _checkResult() {
    try {
      if (SudokuUtilities.isSolved(game)) {
        gameOver = true;
        Timer(const Duration(milliseconds: 500), () {
          showAnimatedDialog<void>(
              animationType: DialogTransitionType.fadeScale,
              barrierDismissible: true,
              duration: const Duration(milliseconds: 350),
              context: context,
              builder: (_) => const AlertGameOver()).whenComplete(() {
            if (AlertGameOver.newGame) {
              _newGame();
              AlertGameOver.newGame = false;
            }
          });
        });
      }
    } on InvalidSudokuConfigurationException {
      return;
    }
  }

  static Future<List<List<List<int>>>> _getNewGame(
      [String difficulty = 'easy']) async {
    final prefs = await SharedPreferences.getInstance();
    final int emptySquares = prefs.getInt('emptySquares') ?? 20;

    SudokuGenerator generator = SudokuGenerator(emptySquares: emptySquares);
    return [generator.newSudoku, generator.newSudokuSolved];
  }

  static List<List<int>> _copyGrid(List<List<int>> grid) {
    return grid.map((row) => [...row]).toList();
  }

  void _setGame(int mode, [String difficulty = 'Easy']) async {
    if (mode == 1) {
      game = List.filled(9, List.filled(9, 0));
      gameSolved = List.filled(9, List.filled(9, 0));
    } else {
      gameList = await _getNewGame(difficulty);
      game = gameList[0];
      gameSolved = gameList[1];
    }
    selectedCell = Position(-1, -1);
  }

  void _showSolution() {
    setState(() {
      game = _copyGrid(gameSolved);
      gameOver = true;
    });
  }

  void _newGame([String difficulty = 'Easy']) {
    setState(() {
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _setGame(2, difficulty);
        gameOver = false;
      });
    });
  }

  Widget buildBoard() {
    if (firstRun) {
      _setGame(1);
      firstRun = false;
    }

    List<Row> rowList = <Row>[];
    for (var row = 0; row < 9; row++) {
      List<SizedBox> buttonList = List<SizedBox>.filled(9, SizedBox());
      for (var col = 0; col < 9; col++) {
        String val = game[row][col] != 0 ? game[row][col].toString() : ' ';
        Color txt_color = Colors.blue;
        if (game[row][col] != 0) {
          if(selectedCell.x != -1 && selectedCell.y != -1) {
            if (game[row][col] == game[selectedCell.x][selectedCell.y]) {
              txt_color = Colors.red;
            }
          }
        }
        buttonList[col] = SizedBox(
            width: buttonSize(),
            height: buttonSize(),
            child: DragTarget<int>(
              onAccept: (data) => setState(() {
                if (game[row][col] == 0) {
                  if (gameSolved[row][col] == data) {
                    game[row][col] = data;
                  } else {
                    print('wrong key');
                  }
                }
              }),
              builder: (context, _, __) => TextButton(
                onPressed: () {
                  setState(() {
                    selectedCell = Position(row, col);
                    selectedKey = 0;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(buttonColor(
                      row,
                      col,
                      (selectedCell.x == row && selectedCell.y == col && game[row][col] == 0))),
                  side: MaterialStateProperty.all<BorderSide>(BorderSide(
                    color: (selectedCell.x == row && selectedCell.y == col)
                        ? Colors.red
                        : Colors.amber,
                    width: (selectedCell.x == row && selectedCell.y == col)
                        ? 2
                        : 1,
                    style: BorderStyle.solid,
                  )),
                ),
                child: Text(
                  val,
                  style: TextStyle(
                    color: txt_color,
                      fontSize: buttonFontSize(),
                      fontFamily: GoogleFonts.kalam().fontFamily),
                ),
              ),
            ));
      }

      rowList.add(Row(
          mainAxisAlignment: MainAxisAlignment.center, children: buttonList));
    }

    return Column(
      children: rowList,
    );
  }

  Widget buildKeyPad() {
    final List<int> numberListAll = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    List<SizedBox> boxes = <SizedBox>[];

    for (int number in numberListAll) {
      boxes.add(SizedBox(
          child: Draggable<int>(
        data: number,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          child: Material(
            borderRadius: BorderRadius.circular(20.0),
            elevation: 8.0,
            child: TextButton(
                onPressed: () {
                  setState(() {
                    selectedKey = number;
                    // if a cell is selected
                    if (selectedCell.x != -1 && selectedCell.y != -1) {
                      // if cell empty
                      if (game[selectedCell.x][selectedCell.y] == 0) {
                        // if correct answer is selected
                        if (gameSolved[selectedCell.x][selectedCell.y] ==
                            selectedKey) {
                          game[selectedCell.x][selectedCell.y] = selectedKey;
                        } else {
                          print('wrong key');
                        }
                      }
                    }
                    selectedKey = 0;
                    selectedCell = Position(-1, -1);
                  });
                },
                child: Text(
                  number.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: buttonFontSize(),
                      fontFamily: GoogleFonts.kalam().fontFamily),
                )),
          ),
        ),
        feedback: Text(
          number.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: buttonFontSize(),
              fontFamily: GoogleFonts.kalam().fontFamily),
        ),
        childWhenDragging: Text(
          " ",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: buttonFontSize(),
              fontFamily: GoogleFonts.kalam().fontFamily),
        ),
      )));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: boxes,
    );
  }

  showOptionModalSheet(BuildContext context) {
    BuildContext outerContext = context;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Styles.secondaryBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        builder: (context) {
          final TextStyle customStyle =
              TextStyle(inherit: false, color: Styles.foregroundColor);
          return Wrap(
            children: [
              ListTile(
                leading:
                    Icon(Icons.build_outlined, color: Styles.foregroundColor),
                title: Text('New Game', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(
                      const Duration(milliseconds: 300),
                      () => showAnimatedDialog<void>(
                              animationType: DialogTransitionType.fadeScale,
                              barrierDismissible: true,
                              duration: const Duration(milliseconds: 350),
                              context: outerContext,
                              builder: (_) => AlertDifficultyState(
                                  currentDifficultyLevel!)).whenComplete(() {
                            if (AlertDifficultyState.difficulty != null) {
                              Timer(const Duration(milliseconds: 300), () {
                                _newGame(
                                    AlertDifficultyState.difficulty ?? 'test');
                                currentDifficultyLevel =
                                    AlertDifficultyState.difficulty;
                                AlertDifficultyState.difficulty = null;
                                setPrefs('currentDifficultyLevel');
                              });
                            }
                          }));
                },
              ),
              ListTile(
                leading: Icon(Icons.invert_colors_on_rounded,
                    color: Styles.foregroundColor),
                title: Text('Switch Theme', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 200), () {
                    _changeTheme('switch');
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.color_lens_outlined,
                    color: Styles.foregroundColor),
                title: Text('Change Accent Color', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(
                      const Duration(milliseconds: 200),
                      () => showAnimatedDialog<void>(
                              animationType: DialogTransitionType.fadeScale,
                              barrierDismissible: true,
                              duration: const Duration(milliseconds: 350),
                              context: outerContext,
                              builder: (_) => AlertAccentColorsState(
                                  currentAccentColor!)).whenComplete(() {
                            if (AlertAccentColorsState.accentColor != null) {
                              Timer(const Duration(milliseconds: 300), () {
                                currentAccentColor =
                                    AlertAccentColorsState.accentColor;
                                _changeAccentColor(
                                    currentAccentColor.toString());
                                AlertAccentColorsState.accentColor = null;
                                setPrefs('currentAccentColor');
                              });
                            }
                          }));
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline_rounded,
                    color: Styles.foregroundColor),
                title: Text('About', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(
                      const Duration(milliseconds: 200),
                      () => showAnimatedDialog<void>(
                          animationType: DialogTransitionType.fadeScale,
                          barrierDismissible: true,
                          duration: const Duration(milliseconds: 350),
                          context: outerContext,
                          builder: (_) => const AlertAbout()));
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (firstRun) {
      _setGame(1);
      firstRun = false;
    }

    return WillPopScope(
        onWillPop: () async {
          if (kIsWeb) {
            return false;
          } else {
            showAnimatedDialog<void>(
                animationType: DialogTransitionType.fadeScale,
                barrierDismissible: true,
                duration: const Duration(milliseconds: 350),
                context: context,
                builder: (_) => const AlertExit());
          }
          return true;
        },
        child: Scaffold(
            backgroundColor: Styles.primaryBackgroundColor,
            resizeToAvoidBottomInset: false,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(56.0),
              child: isDesktop
                  ? MoveWindow(
                      onDoubleTap: () => appWindow.maximizeOrRestore(),
                      child: AppBar(
                        centerTitle: true,
                        title: const Text('Sudoku'),
                        backgroundColor: Styles.primaryColor,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 15),
                            onPressed: () {
                              appWindow.minimize();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                            onPressed: () {
                              showAnimatedDialog<void>(
                                  animationType: DialogTransitionType.fadeScale,
                                  barrierDismissible: true,
                                  duration: const Duration(milliseconds: 350),
                                  context: context,
                                  builder: (_) => const AlertExit());
                            },
                          ),
                        ],
                      ),
                    )
                  : AppBar(
                      centerTitle: true,
                      title: const Text('Sudoku'),
                      backgroundColor: Styles.primaryColor,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            //Navigator.pop(context);
                            Timer(const Duration(milliseconds: 200),
                                () => _newGame());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.lightbulb_outline_rounded),
                          padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                          onPressed: () {
                            //Navigator.pop(context);
                            Timer(const Duration(milliseconds: 200),
                                () => _showSolution());
                          },
                        ),
                      ],
                    ),
            ),
            body: Builder(builder: (builder) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildBoard(),
                    SizedBox(height: 10),
                    buildKeyPad(),
                  ],
                ),
              );
            }),
            floatingActionButton: FloatingActionButton(
              foregroundColor: Styles.primaryBackgroundColor,
              backgroundColor: isFABDisabled
                  ? Styles.primaryColor[900]
                  : Styles.primaryColor,
              onPressed:
                  isFABDisabled ? null : () => showOptionModalSheet(context),
              child: const Icon(Icons.menu_rounded),
            )));
  }
}
