import 'package:flutter/material.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/ui/home.dart';
import 'package:remorder/ui/remo_transmission.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    RemoBloc remoBloc = RemoBloc();
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      child: MaterialApp(
        title: 'Remo physiotherapy',
        theme: ThemeData(
          // Morecognition dark blue.
          primaryColor: Color.fromRGBO(49, 61, 83, 1),
          // Morecognition light green.
          accentColor: Color.fromRGBO(93, 225, 167, 1),
          primarySwatch: () {
            // Morecognition light green.
            Map<int, Color> swatch = {
              50: Color.fromRGBO(93, 225, 167, .1),
              100: Color.fromRGBO(93, 225, 167, .2),
              200: Color.fromRGBO(93, 225, 167, .3),
              300: Color.fromRGBO(93, 225, 167, .4),
              400: Color.fromRGBO(93, 225, 167, .5),
              500: Color.fromRGBO(93, 225, 167, .6),
              600: Color.fromRGBO(93, 225, 167, .7),
              700: Color.fromRGBO(93, 225, 167, .8),
              800: Color.fromRGBO(93, 225, 167, .9),
              900: Color.fromRGBO(93, 225, 167, 1),
            };

            return MaterialColor(Color.fromRGBO(49, 61, 83, 1).value, swatch);
          }(),
          // Morecognition dark blue.
          buttonColor: Color.fromRGBO(49, 61, 83, 1),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: TextTheme(
            button: TextStyle(
              fontSize: 16,
              fontFamily: 'Isidora Sans SemiBold',
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
          ),
          tabBarTheme: TabBarTheme(
            labelColor: Color.fromRGBO(93, 225, 167, 1),
            unselectedLabelColor: Colors.white70,
          ),
          // Light grey.
          cardColor: Color.fromRGBO(242, 243, 244, 1),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            // Morecognition dark blue.
            backgroundColor: Color.fromRGBO(49, 61, 83, 1),
            // Light grey.
            unselectedIconTheme:
                IconThemeData(color: Color.fromRGBO(242, 243, 244, 1)),
            // Light grey.
            unselectedItemColor: Color.fromRGBO(242, 243, 244, 1),
            // Morecognition light green
            selectedItemColor: Color.fromRGBO(93, 225, 167, 1),
          ),
        ),
        routes: {
          '/': (context) => Home(),
          '/remo_connection': (context) => RemoConnection(remoBloc: remoBloc),
          '/remo_transmission': (context) =>
              RemoTransmission(remoBloc: remoBloc),
        },
        initialRoute: '/',
      ),
    );
  }
}
