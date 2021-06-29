import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
              _DataChart chart =
                  _DataChart(remoDataStream: remoState.remoDataStream);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  chart,
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

class _ChartData {
  final int emgValue;
  final int timestamp;

  _ChartData({required this.emgValue, required this.timestamp});
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
    return SfCartesianChart(
      legend: Legend(isVisible: true),
      primaryXAxis: CategoryAxis(),
      series: List<LineSeries>.generate(
        channels,
        (index) {
          return LineSeries<_ChartData, int>(
            onRendererCreated: (controller) {
              _chartSeriesControllers.add(controller);
            },
            dataSource: _emgChannels[index],
            xValueMapper: (_ChartData data, _) => data.timestamp,
            yValueMapper: (_ChartData data, _) => data.emgValue,
          );
        },
      ),
    );
  }

  _DataChartState(this.remoDataStream) {
    _emgChannels =
        List.filled(channels, List<_ChartData>.empty(growable: true));
    for (int i = 0; i < _windowSize; ++i) {
      for (var list in _emgChannels) {
        list.add(_ChartData(emgValue: 0, timestamp: count));
      }
      ++count;
    }
    remoDataStream.listen(
      (remoData) {
        setState(
          () {
            for (int i = 0; i < channels; ++i) {
              _emgChannels[i].removeAt(0);
              _emgChannels[i].add(
                _ChartData(emgValue: remoData.emg[i], timestamp: count),
              );
              _chartSeriesControllers[i].updateDataSource(
                addedDataIndex: _windowSize - 1,
                removedDataIndex: 0,
              );
            }
            ++count;
          },
        );
      },
    );
  }

  List<ChartSeriesController> _chartSeriesControllers =
      List.empty(growable: true);
  static int count = 0;
  // Number of samples to keep in the graph;
  static const int _windowSize = 50;
  // 8 is the number of EMG channels available in Remo.
  static const int channels = 8;
  late List<List<_ChartData>> _emgChannels;

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
