import 'package:flutter/material.dart';

import '../style/styles.dart';
import '../style/button_style.dart';

class KeyPadNumbers {
  // ignore: avoid_init_to_null
  static int? number = null;
  late int numberSelected;
  static final List<int> numberListAll = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  List<SizedBox> createButtons(List<int> numberList) {
    return <SizedBox>[
      for (int numbers in numberList)
        SizedBox(
          width: buttonSize(),
          height: buttonSize(),
          child: TextButton(
            onPressed: () {
              //setState(() {
                numberSelected = numbers;
                number = numberSelected;
                //Navigator.pop(context);
             // })
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Styles.secondaryBackgroundColor),
              foregroundColor:
                  MaterialStateProperty.all<Color>(Styles.primaryColor),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                borderRadius: buttonEdgeRadius(0, numbers - 1, 1),
              )),
              side: MaterialStateProperty.all<BorderSide>(BorderSide(
                color: Styles.foregroundColor,
                width: 1,
                style: BorderStyle.solid,
              )),
            ),
            child: Text(
              numbers.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: buttonFontSize()),
            ),
          ),
        )
    ];
  }

  List<Row> createKeyPad() {
    List<Row> rowList = <Row>[];
    Row oneRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: createButtons(numberListAll),
    );

    rowList.add(oneRow);
    return rowList;
  }

}
