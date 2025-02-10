import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:design_sync/design_sync.dart';
import 'package:remorder/ui/pages/home.dart';
import 'package:remorder/ui/pages/paring_page.dart';
import 'package:remorder/ui/pages/remo_connection.dart';
import 'package:remorder/ui/pages/remo_transmission.dart';
import 'package:remorder/ui/pages/save_page.dart';

void main() {
  DesignSync.initialize(figmaCanvasSize: Size(375, 812));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BluetoothBloc>(create: (context) => BluetoothBloc()),
          BlocProvider<RemoBloc>(create: (context) => RemoBloc()),
          BlocProvider<RemoFileBloc>(create: (context) => RemoFileBloc())
        ],
        child: MaterialApp(
          title: 'Remo physiotherapy',
          theme: ThemeData(
            // Morecognition dark blue.
            primaryColor: const Color(0xFF80D0D4),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Poppins',
            textTheme: const TextTheme(
              labelLarge: TextStyle(
                fontSize: 16,
                fontFamily: 'Isidora Sans SemiBold',
                color: Color.fromRGBO(255, 255, 255, 1),
              ),
            ),
            tabBarTheme: const TabBarTheme(
              labelColor: Color.fromRGBO(93, 225, 167, 1),
              unselectedLabelColor: Colors.white70,
            ),
            // Light grey.
            cardColor: const Color.fromRGBO(242, 243, 244, 1),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
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
            colorScheme: ColorScheme.fromSwatch(primarySwatch: () {
              // Morecognition light green.
              Map<int, Color> swatch = {
                50: const Color.fromRGBO(93, 225, 167, .1),
                100: const Color.fromRGBO(93, 225, 167, .2),
                200: const Color.fromRGBO(93, 225, 167, .3),
                300: const Color.fromRGBO(93, 225, 167, .4),
                400: const Color.fromRGBO(93, 225, 167, .5),
                500: const Color.fromRGBO(93, 225, 167, .6),
                600: const Color.fromRGBO(93, 225, 167, .7),
                700: const Color.fromRGBO(93, 225, 167, .8),
                800: const Color.fromRGBO(93, 225, 167, .9),
                900: const Color.fromRGBO(93, 225, 167, 1),
              };

              return MaterialColor(
                  const Color.fromRGBO(49, 61, 83, 1).value, swatch);
            }())
                .copyWith(secondary: const Color.fromRGBO(93, 225, 167, 1)),
          ),
          routes: {
            '/pairing': (context) => const PairingPage(),
            '/pairing/connection': (context) => const RemoConnection(),
            '/home': (context) => const Home(),
            '/remo_transmission': (context) => const RemoTransmission(),
            '/save_page': (context) => const SavePage(),
          },
          initialRoute: '/pairing',
        ),
      ),
    );
  }
}
