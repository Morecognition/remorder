import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:path_provider/path_provider.dart';

class RemoTransmission extends StatelessWidget {
  Future<void> saveFile(String data) async {}

  @override
  Widget build(BuildContext _) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: BlocBuilder<RemoBloc, RemoState>(
          builder: (builderContext, remoState) {
            if (remoState is Connected) {
              return IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  BlocProvider.of<RemoBloc>(builderContext)
                      .add(OnStartTransmission());
                },
              );
            } else if (remoState is StartingTransmission) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (remoState is TransmissionStarted) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _DataChart(remoDataStream: remoState.remoDataStream),
                  )),
                  SizedBox(height: 40),
                  IconButton(
                    icon: Icon(Icons.stop),
                    onPressed: () {
                      BlocProvider.of<RemoBloc>(builderContext)
                          .add(OnStopTransmission());
                    },
                  ),
                ],
              );
            } else {
              return Center(
                child: Text(
                    'Unhandled state: ' + remoState.runtimeType.toString()),
              );
            }
          },
        ),
      ),
    );
  }
}

class _DataChart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DataChartState(remoDataStream);
  }

  const _DataChart({Key? key, required this.remoDataStream}) : super(key: key);
  final Stream<RemoData> remoDataStream;
}

class _DataChartState extends State<_DataChart> {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 30000,
        lineTouchData: LineTouchData(enabled: false),
        clipData: FlClipData.all(),
        gridData: FlGridData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: _emgChannels[0],
            dotData: FlDotData(show: false),
            isCurved: false,
            colors: [Colors.grey],
          ),
          LineChartBarData(
            spots: _emgChannels[1],
            dotData: FlDotData(show: false),
            isCurved: false,
            colors: [Colors.red],
          ),
          LineChartBarData(
            spots: _emgChannels[2],
            dotData: FlDotData(show: false),
            isCurved: false,
            colors: [Colors.amber],
          ),
          LineChartBarData(
            spots: _emgChannels[3],
            dotData: FlDotData(show: false),
            isCurved: false,
            colors: [Colors.lime],
          ),
          LineChartBarData(
            spots: _emgChannels[4],
            dotData: FlDotData(show: false),
            isCurved: false,
            colors: [Colors.purple],
          ),
          LineChartBarData(
            spots: _emgChannels[5],
            dotData: FlDotData(show: false),
            isCurved: false,
            colors: [Colors.yellow],
          ),
          LineChartBarData(
            spots: _emgChannels[6],
            dotData: FlDotData(show: false),
            isCurved: false,
            colors: [Colors.blue],
          ),
          LineChartBarData(
            spots: _emgChannels[7],
            dotData: FlDotData(show: false),
            isCurved: false,
            colors: [Colors.black],
          ),
        ],
      ),
      swapAnimationDuration: Duration(milliseconds: 0),
    );
  }

  _DataChartState(this.remoDataStream) {
    _emgChannels = List.filled(channels, List<FlSpot>.empty(growable: true));
    for (int i = 0; i < _windowSize; ++i) {
      for (var list in _emgChannels) {
        list.add(FlSpot(xvalue, 0));
      }
      xvalue += step;
    }
    remoDataStream.listen(
      (remoData) {
        for (int i = 0; i < channels; ++i) {
          _emgChannels[i].removeAt(0);
          _emgChannels[i].add(
            FlSpot(xvalue, remoData.emg[i].toDouble()),
          );
        }
        setState(
          () {
            xvalue += step;
          },
        );
      },
    );
  }

  double xvalue = 0;
  double step = 0.05;

  // Number of samples to keep in the graph;
  static const int _windowSize = 100;
  // 8 is the number of EMG channels available in Remo.
  static const int channels = 8;
  late List<List<FlSpot>> _emgChannels;

  final Stream<RemoData> remoDataStream;
}

class _SavePrompt extends StatefulWidget {
  const _SavePrompt({Key? key, required this.remoData}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SaveState(remoData);
  }

  final String remoData;
}

class _SaveState extends State<_SavePrompt> {
  final String remoData;
  String _fileName = '';

  _SaveState(this.remoData);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          child: TextField(
            onChanged: (value) {
              _fileName = value;
            },
          ),
        ),
        TextButton(
          onPressed: () async {
            if (_fileName.isEmpty) {
              return;
            }

            final Directory? directory = await getExternalStorageDirectory();
            if (directory == null) {
              return;
            }

            final String path = directory.path + '/' + _fileName;

            File file = File(path);
            file.writeAsString(remoData);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
