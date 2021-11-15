import 'dart:async';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakelock/wakelock.dart';

class RemoTransmission extends StatelessWidget {
  @override
  Widget build(BuildContext _) {
    Future<Directory> tmpDirectory = getTemporaryDirectory();
    Future<Directory?> externalStorageDirectory = getExternalStorageDirectory();
    final String tmpFileName = 'tmpFileName';
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: BlocBuilder<RemoBloc, RemoState>(
          builder: (builderContext, remoState) {
            if (remoState is Connected) {
              return IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  Wakelock.enable();
                  BlocProvider.of<RemoBloc>(builderContext)
                      .add(OnStartTransmission());
                },
              );
            } else if (remoState is StartingTransmission ||
                remoState is StoppingTransmission) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (remoState is TransmissionStarted) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Container(
                    height: 45,
                    width: MediaQuery.of(builderContext).size.width * 0.95,
                    child: Row(
                      children: [
                        _ColorLabel(color: Colors.red, text: 'Ch1'),
                        Spacer(),
                        _ColorLabel(color: Colors.pink, text: 'Ch2'),
                        Spacer(),
                        _ColorLabel(color: Colors.orange, text: 'Ch3'),
                        Spacer(),
                        _ColorLabel(color: Colors.yellow, text: 'Ch4'),
                        Spacer(),
                        _ColorLabel(color: Colors.green, text: 'Ch5'),
                        Spacer(),
                        _ColorLabel(color: Colors.green.shade900, text: 'Ch6'),
                        Spacer(),
                        _ColorLabel(color: Colors.blue, text: 'Ch7'),
                        Spacer(),
                        _ColorLabel(color: Colors.grey, text: 'Ch8'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder<Directory?>(
                        future: tmpDirectory,
                        builder: (BuildContext context,
                            AsyncSnapshot<Directory?> snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            // Creating file handle.
                            String path = snapshot.data!.path;
                            File csvFile = File('$path/$tmpFileName.csv');

                            return _DataChart(
                              remoDataStream: remoState.remoDataStream,
                              tmpDirectory: snapshot.data!,
                              csvFile: csvFile,
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  IconButton(
                    icon: Icon(Icons.stop),
                    onPressed: () {
                      Wakelock.disable();
                      BlocProvider.of<RemoBloc>(builderContext).add(
                        OnStopTransmission(),
                      );
                    },
                  ),
                  SizedBox(height: 15),
                ],
              );
            } else if (remoState is Disconnected) {
              return Center(
                child: Text('Please go back and connect Remo.'),
              );
            } else if (remoState is TransmissionStopped) {
              return FutureBuilder(
                future: Future.wait([tmpDirectory, externalStorageDirectory]),
                builder: (BuildContext context,
                    AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data![0] != null &&
                      snapshot.data![1] != null) {
                    return _SavePrompt(
                      tmpDirectory: snapshot.data![0]! as Directory,
                      externalStorageDirectory: snapshot.data![1]! as Directory,
                      tmpFileName: tmpFileName,
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              );
            } else {
              return Center(
                child: Text(
                  'Unhandled state: ' + remoState.runtimeType.toString(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class _ColorLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            color: color,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          width: 30,
          height: 25,
        ),
        Text(text),
      ],
    );
  }

  const _ColorLabel({Key? key, required this.color, required this.text})
      : super(key: key);
  final Color color;
  final String text;
}

class _DataChart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DataChartState(
      remoDataStream: remoDataStream,
      tmpDirectory: tmpDirectory,
    );
  }

  const _DataChart({
    Key? key,
    required this.remoDataStream,
    required this.tmpDirectory,
    required this.csvFile,
  }) : super(key: key);

  final Stream<RemoData> remoDataStream;
  final Directory tmpDirectory;
  final File csvFile;
}

class _DataChartState extends State<_DataChart> {
  @override
  Widget build(BuildContext context) {
    late double minY;
    late double maxY;
    switch (BlocProvider.of<RemoBloc>(context).transmissionMode) {
      case TransmissionMode.rms:
        minY = 0;
        maxY = 20;
        break;
      case TransmissionMode.rawImu:
        minY = -15;
        maxY = 15;
        break;
    }

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        minX: _emgChannels[0].first.x,
        maxX: _emgChannels[0].last.x,
        lineTouchData: LineTouchData(enabled: false),
        clipData: FlClipData.all(),
        gridData: FlGridData(show: true),
        lineBarsData: [
          emgLine(0, Colors.red),
          emgLine(1, Colors.pink),
          emgLine(2, Colors.orange),
          emgLine(3, Colors.yellow),
          emgLine(4, Colors.green),
          emgLine(5, Colors.green.shade900),
          emgLine(6, Colors.blue),
          emgLine(7, Colors.grey),
        ],
        axisTitleData: FlAxisTitleData(
          leftTitle: AxisTitle(
              showTitle: true,
              titleText: 'millivolt',
              margin: 0,
              textAlign: TextAlign.right),
          bottomTitle: AxisTitle(
              showTitle: true,
              titleText: 'samples',
              margin: 0,
              textAlign: TextAlign.right),
        ),
      ),
      swapAnimationDuration: Duration.zero,
    );
  }

  LineChartBarData emgLine(int emgIndex, Color color) {
    return LineChartBarData(
      spots: _emgChannels[emgIndex],
      dotData: FlDotData(show: false),
      isCurved: false,
      colors: [color],
      barWidth: 2,
    );
  }

  @override
  void initState() {
    super.initState();

    // Listening to Remo.
    remoStreamSubscription = remoDataStream.listen(
      (remoData) {
        setState(
          () {
            // Adding EMG values to the chart's buffer.
            for (int i = 0; i < channels; ++i) {
              _emgChannels[i].add(
                FlSpot(xvalue, remoData.emg[i]),
              );
              _emgChannels[i].removeAt(0);
            }
            xvalue += step;

            fileSink.write(remoData.toCsvString());
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    remoStreamSubscription.cancel();

    fileSink.flush();
    fileSink.close();
  }

  _DataChartState({
    required this.remoDataStream,
    required this.tmpDirectory,
  });

  double xvalue = 0;
  double step = 0.05;

  // Number of samples to keep in the graph;
  static const int _windowSize = 100;
  // 8 is the number of EMG channels available in Remo.
  static const int channels = 8;
  List<List<FlSpot>> _emgChannels = List.generate(
    channels,
    (int) => List<FlSpot>.generate(
      _windowSize,
      (int) => FlSpot(0, 0),
      growable: true,
    ),
  );

  late Directory tempDir;

  late final StreamSubscription<RemoData> remoStreamSubscription;
  final Stream<RemoData> remoDataStream;
  final Directory tmpDirectory;

  late IOSink fileSink = widget.csvFile.openWrite();
}

class _SavePrompt extends StatefulWidget {
  const _SavePrompt(
      {Key? key,
      required this.tmpDirectory,
      required this.tmpFileName,
      required this.externalStorageDirectory})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SaveState(
        tmpDirectory: tmpDirectory,
        tmpFileName: tmpFileName,
        externalStorageDirectory: externalStorageDirectory);
  }

  final Directory tmpDirectory;
  final Directory externalStorageDirectory;
  final String tmpFileName;
}

class _SaveState extends State<_SavePrompt> {
  final Directory tmpDirectory;
  final Directory externalStorageDirectory;
  final String tmpFileName;
  late String selectedFileName = tmpFileName;

  final _formKey = GlobalKey<FormState>();

  _SaveState({
    required this.tmpDirectory,
    required this.tmpFileName,
    required this.externalStorageDirectory,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Insert file name:'),
        SizedBox(height: 20),
        Container(
          width: 200,
          child: Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  selectedFileName = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'You need to name it';
                }
                return null;
              },
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).accentColor),
              onPressed: () async {
                final String tmpFilePath = tmpDirectory.path + '/$tmpFileName';

                File tmpCsvFile = File(tmpFilePath + '.csv');

                await tmpCsvFile.delete();

                BlocProvider.of<RemoBloc>(context).add(OnResetTransmission());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Recorded values discarded'),
                  ),
                );
              },
              child: Text('Discard'),
            ),
            SizedBox(width: 50),
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).accentColor),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final String newFilePath =
                      externalStorageDirectory.path + '/$selectedFileName';
                  final String tmpFilePath =
                      tmpDirectory.path + '/$tmpFileName';

                  File tmpCsvFile = File(tmpFilePath + '.csv');
                  await tmpCsvFile.copy(newFilePath + '.csv');

                  await tmpCsvFile.delete();

                  BlocProvider.of<RemoBloc>(context).add(OnResetTransmission());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'File successfully saved as $selectedFileName.csv'),
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
