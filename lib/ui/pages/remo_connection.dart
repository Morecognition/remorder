import 'package:design_sync/design_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/ui/components/loading_ring.dart';

class RemoConnection extends StatelessWidget {
  const RemoConnection({super.key});

  @override
  Widget build(BuildContext context) {
    //return _buildParingFailedWidget(context);
    return BlocBuilder<BluetoothBloc, BluetoothState>(
        builder: (context, bluetoothState) {
      return BlocBuilder<RemoBloc, RemoState>(
          builder: (context, remoState) {
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
                title: _getAppTitle(bluetoothState, remoState)),
            backgroundColor: const Color(0xFFF6F7FF),
            body: Builder(builder: (context) {
              if (bluetoothState is BluetoothInitial) {
                context.read<BluetoothBloc>().add(OnStartDiscovery());
              }

              if (remoState is Disconnected) {
                if (bluetoothState is DiscoveringDevices) {
                  return _buildWaitingWidget();
                } else if (bluetoothState is DiscoveredDevices) {
                  return _buildDeviceListWidget(context, bluetoothState);
                } else {
                  return Text("$bluetoothState");
                }
              } else if (remoState is Connecting) {
                return _buildWaitingWidget();
              } else if (remoState is Connected) {
                return _buildParingSuccessfulWidget(context);
              } else if (remoState is ConnectionError) {
                return _buildParingFailedWidget(context);
              } else {
                return Text("$remoState");
              }
            }));
      });
    });
  }

  Widget _getAppTitle(BluetoothState bluetoothState, RemoState remoState) {
    return Builder(builder: (context) {
      if (remoState is Disconnected) {
        if (bluetoothState is DiscoveringDevices) {
          return const Text("Looking for REMO...");
        } else if (bluetoothState is DiscoveredDevices) {
          return const Text("Choose your device");
        } else {
          return Text("$bluetoothState");
        }
      } else if (remoState is Connecting) {
        return const Text("Pairing...");
      } else if (remoState is Connected) {
        return const Text("Pairing successful");
      } else if (remoState is ConnectionError) {
        return const Text("Pairing failed");
      } else {
        return Text("$remoState");
      }
    });
  }

  Widget _buildWaitingWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(alignment: Alignment.center, children: <Widget>[
            Image.asset(
              'assets/remo_icon.png',
            ),
            LoadingRing(),
            LoadingRing(startDelay: Duration(milliseconds: 1500))
          ])
        ],
      ),
    );
  }

  Widget _buildDeviceListWidget(
      BuildContext context, DiscoveredDevices bluetoothState) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: List.generate(bluetoothState.deviceNames.length, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.adaptedHeight, horizontal: 17.adaptedWidth),
          child: ListTile(
            leading: Image.asset("assets/remo.png"),
            title: Text(
              bluetoothState.deviceNames[index],
              style: TextStyle(
                  color: Color(0xFF2B3A51), fontWeight: FontWeight.w600),
            ),
            //subtitle: Text(bluetoothState.deviceAddresses[index]),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.adaptedRadius),
            ),
            tileColor: Color(0x0E2B3A51),
            onTap: () {
              context.read<RemoBloc>().add(
                    OnConnectDevice(bluetoothState.deviceAddresses[index]),
                  );
            },
          ),
        );
      }),
    );
  }

  Widget _buildParingSuccessfulWidget(BuildContext context) {
    Future.delayed(Duration(seconds: 2),
        () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, "/home");
        });
    return Center(
      child: Image.asset(
        'assets/remo_success.png',
      ),
    );
  }

  Widget _buildParingFailedWidget(BuildContext context) {
    return Center(
        child: Column(children: [
      Image.asset(
        'assets/remo_fail.png',
      ),
      SizedBox(height: 170.adaptedHeight),
      const Text("Wear Remo and turn it on"),
      SizedBox(height: 10.adaptedHeight),
      const Text("Turn on Bluetooth on your device"),
      SizedBox(height: 42.adaptedHeight),
      FilledButton(
        onPressed: () {
          Navigator.pop(context);
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
        child: Text('Try again',
            style: TextStyle(
                fontSize: 20.adaptedFontSize, fontWeight: FontWeight.w600)),
      ),
    ]));
  }
}
