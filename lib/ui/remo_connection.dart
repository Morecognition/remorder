import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WearRemoStep extends StatelessWidget {
  const WearRemoStep({super.key});

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();
    return Scaffold(
      appBar: AppBar(
        title: const Text("1/4"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close))
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Wear Remo and turn it on"),
              Container(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/wear_remo.png',
                  package: 'flutter_remo',
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TurnOnBluetoothStep(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary),
                child: const Text('NEXT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TurnOnBluetoothStep extends StatelessWidget {
  const TurnOnBluetoothStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("2/4"),
        actions: [
          IconButton(
              onPressed: () {
                int count = 0;
                Navigator.of(context).popUntil((route) => count++ == 2);
              },
              icon: const Icon(Icons.close))
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Turn on bluetooth on your device'),
              Image.asset(
                'assets/bluetooth.png',
                package: 'flutter_remo',
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  var bluetoothScan = await Permission.bluetoothScan.request();
                  var bluetoothConnect =
                      await Permission.bluetoothConnect.request();
                  if (bluetoothScan.isGranted &&
                      bluetoothConnect.isGranted &&
                      context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => BluetoothBloc(),
                          child: const BluetoothStep(),
                        ),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Bluetooth permisison'),
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
                },
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary),
                child: const Text('SCAN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Switch extends StatefulWidget {
  const _Switch({
    Key? key,
  }) : super(key: key);

  @override
  State<_Switch> createState() => _SwitchState();
}

class _SwitchState extends State<_Switch> {
  bool _value = false;
  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      onChanged: (value) {
        setState(() {
          _value = value;
        });
        BlocProvider.of<RemoBloc>(context).add(OnSwitchTransmissionMode());
      },
    );
  }
}

class BluetoothStep extends StatelessWidget {
  const BluetoothStep({super.key});

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<BluetoothBloc>(context).add(OnStartDiscovery());
    return Scaffold(
      appBar: AppBar(
        title: const Text("3/4"),
        actions: [
          IconButton(
              onPressed: () {
                int count = 0;
                Navigator.of(context).popUntil((route) => count++ == 3);
              },
              icon: const Icon(Icons.close))
        ],
      ),
      body: BlocBuilder<BluetoothBloc, BluetoothState>(
        builder: (context, bluetoothState) {
          late Widget widget;
          if (bluetoothState is DiscoveredDevices) {
            widget = RefreshIndicator(
              onRefresh: () async {
                // When the widget is scrolled down a refresh event is sent to the bloc.
                BlocProvider.of<BluetoothBloc>(context).add(OnStartDiscovery());
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children:
                    List.generate(bluetoothState.deviceNames.length, (index) {
                  return ListTile(
                    title: Text(bluetoothState.deviceNames[index]),
                    subtitle: Text(bluetoothState.deviceAddresses[index]),
                    onTap: () {
                      // When the text button is pressed, tell the block which device it has to connect to.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RemoConnectionStep(
                              bluetoothAddress:
                                  bluetoothState.deviceAddresses[index]),
                        ),
                      );
                    },
                  );
                }),
              ),
            );
          } else if (bluetoothState is DiscoveringDevices) {
            widget = const Center(child: CircularProgressIndicator());
          } else if (bluetoothState is DiscoveryError) {
            widget = const Center(child: Text("Discovery error."));
          } else if (bluetoothState is BluetoothInitial) {
            widget = Center(
              child: MaterialButton(
                color: Theme.of(context).colorScheme.secondary,
                shape: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(30),
                  child: Text("Discover"),
                ),
                onPressed: () async {
                  if (await Permission.locationWhenInUse.request().isGranted &&
                      await Permission.bluetooth.request().isGranted &&
                      context.mounted) {
                    BlocProvider.of<BluetoothBloc>(context)
                        .add(OnStartDiscovery());
                  }
                },
              ),
            );
          }
          return widget;
        },
      ),
    );
  }
}

class RemoConnectionStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('4/4'),
        actions: [
          IconButton(
            onPressed: () {
              int count = 0;
              Navigator.of(context).popUntil((route) => count++ == 4);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: BlocBuilder<RemoBloc, RemoState>(
        builder: (context, state) {
          if (state is Disconnected) {
            return Center(
              child: TextButton(
                  onPressed: () {
                    BlocProvider.of<RemoBloc>(context).add(
                      OnConnectDevice(bluetoothAddress),
                    );
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary),
                  child: const Text('Connect')),
            );
          } else if (state is Connecting) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is Connected) {
            return Center(
              child: TextButton(
                  onPressed: () {
                    int count = 0;
                    Navigator.of(context).popUntil((route) => count++ == 4);
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary),
                  child: const Text('Finish')),
            );
          } else if (state is ConnectionError) {
            return const Center(
              child: Text('Connection error'),
            );
          } else if (state is Disconnecting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Text('Unhandled state: ${state.runtimeType}');
          }
        },
      ),
    );
  }

  const RemoConnectionStep({Key? key, required this.bluetoothAddress})
      : super(key: key);
  final String bluetoothAddress;
}
