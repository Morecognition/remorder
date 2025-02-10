import 'dart:io';

import 'package:design_sync/design_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/home_background.png",
          fit: BoxFit.fitHeight,
        ),
        Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20.adaptedFontSize,
                fontWeight: FontWeight.w600),
            toolbarHeight: 80.adaptedHeight,
            title: const Text('Welcome to Remorder'),
          ),
          backgroundColor: Colors.transparent,
          body: BlocBuilder<RemoBloc, RemoState>(
            builder: (context, remoState) {
              var deviceName = context.read<RemoBloc>().currentDeviceName;
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 50.adaptedHeight),
                    Image.asset(
                      remoState is! Disconnected ? 'assets/remo_check.png' : 'assets/remo_fail.png',
                    ),
                    SizedBox(height: 14.adaptedHeight),
                    Text("Device",
                        style: TextStyle(
                            color: Color(0xFF4B4F58),
                            fontSize: 15.adaptedFontSize
                        )),
                    Text(deviceName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 16.adaptedFontSize
                    )),
                    SizedBox(height: 21.adaptedHeight),
                    DecoratedBox(
                        decoration: BoxDecoration(
                            color: Color(0xFF2B3A51),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.5.adaptedRadius))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
                          child: Text(remoState is! Disconnected ? "Connected" : "Disconnected",
                            style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600
                          ),),
                        )),
                    Spacer(),
                    FilledButton(
                      onPressed: () {
                        goToNextPage(context);
                      },
                      style: FilledButton.styleFrom(
                        fixedSize: Size(
                          343.adaptedWidth,
                          48.adaptedHeight,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(60.adaptedRadius))),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text('Start',
                          style: TextStyle(
                              fontSize: 20.adaptedFontSize,
                              fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(height: 25.adaptedHeight),
                    TextButton(
                      onPressed: () {},
                      child: Text('Choose another device',
                          style: TextStyle(
                          fontSize: 20.adaptedFontSize,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(height: 40.adaptedHeight),
                  ],
                ),
              );
            }
          ),
        ),
      ],
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
      Navigator.pushNamed(context, '/remo_transmission');
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
