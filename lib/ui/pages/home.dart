import 'dart:io';

import 'package:design_sync/design_sync.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20.adaptedFontSize,
            fontWeight: FontWeight.w600),
        toolbarHeight: 110.adaptedHeight,
        title: const Text('Welcome to Remorder'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/remo_check.png',
            ),
            Text("Device"),
            Text("REMO005"),
            DecoratedBox(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(12.5.adaptedRadius))),
                child: Text("Connected")),
            FilledButton(
              onPressed: () {
                goToNextPage(context);
              },
              style: FilledButton.styleFrom(
                fixedSize: Size(
                  343.adaptedWidth,
                  48.adaptedHeight,
                ),
                shape: ContinuousRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(24.adaptedRadius))),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text('Start',
                  style: TextStyle(
                      fontSize: 20.adaptedFontSize,
                      fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Choose another device '),
            ),
          ],
        ),
      ),
    );
  }

  void goToNextPage(BuildContext context) async {
    var bluetoothScan = await Permission.bluetoothScan.request();
    var bluetoothConnect = await Permission.bluetoothConnect.request();
    await Permission.bluetooth.request();

    var locationUse = PermissionStatus.granted;

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt <= 30) {
        locationUse = await Permission.locationWhenInUse.request();
      }
    }

    if (bluetoothScan.isGranted &&
        bluetoothConnect.isGranted &&
        locationUse.isGranted &&
        context.mounted) {
      Navigator.pushNamed(context, '/pairing/connection');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Bluetooth permission'),
            content: const Text(
                'Remo needs Bluetooth permissions in order to connect with the device.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
