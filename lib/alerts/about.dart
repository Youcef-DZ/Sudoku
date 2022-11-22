import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../src/game_internals/sudoku.dart';
import '../src/style/styles.dart';

class AlertAbout extends StatelessWidget {
  static const String authorURL = "";
  static const String releasesURL = "";
  static const String sourceURL = "";
  static const String licenseURL = "";

  const AlertAbout({Key? key}) : super(key: key);

  openURL(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Styles.secondaryBackgroundColor,
      title: Center(
        child: Text(
          'About',
          style: TextStyle(color: Styles.foregroundColor),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icon/icon_round.png',
                  height: 48.0, width: 48.0, fit: BoxFit.contain),
              Text(
                '   Sudoku',
                style: TextStyle(
                    color: Styles.foregroundColor,
                    fontFamily: 'roboto',
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '                ',
                style: TextStyle(
                    color: Styles.foregroundColor,
                    fontFamily: 'roboto',
                    fontSize: 15),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Version: ',
                style: TextStyle(
                    color: Styles.foregroundColor,
                    fontFamily: 'roboto',
                    fontSize: 15),
              ),
              InkWell(
                onTap: () => openURL(releasesURL),
                child: Text(
                  '${Sudoku.versionNumber} ',
                  style: TextStyle(
                      color: Styles.primaryColor,
                      fontFamily: 'roboto',
                      fontSize: 15),
                ),
              ),
              Text(
                HomePageState.platform,
                style: TextStyle(
                    color: Styles.foregroundColor,
                    fontFamily: 'roboto',
                    fontSize: 15),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '                ',
                style: TextStyle(
                    color: Styles.foregroundColor,
                    fontFamily: 'roboto',
                    fontSize: 15),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Developer: ',
                style: TextStyle(
                    color: Styles.foregroundColor,
                    fontFamily: 'roboto',
                    fontSize: 15),
              ),
              InkWell(
                onTap: () => openURL(authorURL),
                child: Text(
                  'Surfeed',
                  style: TextStyle(
                      color: Styles.primaryColor,
                      fontFamily: 'roboto',
                      fontSize: 15),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
