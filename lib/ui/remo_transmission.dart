import 'dart:io';
import 'dart:math';

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
              // Number of samples to keep in the graph;
              const int samples = 50;
              // 8 is the number of EMG channels available in Remo.
              const int channels = 8;
              int count = 0;
              var rng = new Random();
              List<List<_ChartData>> emgChannels =
                  List<List<_ChartData>>.filled(
                      channels,
                      List<_ChartData>.generate(
                          samples,
                          (index) => _ChartData(
                              emgValue: rng.nextInt(10), timestamp: count++)));

              // Updating the chart as data comes.
              remoState.remoDataStream.listen(
                (remoData) {
                  for (int i = 0; i < channels; ++i) {
                    emgChannels[i].removeAt(0);
                    emgChannels[i].add(
                        _ChartData(emgValue: remoData.emg[i], timestamp: 0));
                  }
                },
              );

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SfCartesianChart(
                    legend: Legend(isVisible: true),
                    primaryXAxis: CategoryAxis(),
                    series: List<LineSeries>.generate(
                      channels,
                      (index) {
                        return LineSeries<_ChartData, int>(
                            dataSource: emgChannels[index],
                            xValueMapper: (_ChartData data, _) =>
                                data.timestamp,
                            yValueMapper: (_ChartData data, _) =>
                                data.emgValue);
                      },
                    ),
                  ),
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
    // TODO: implement createState
    throw UnimplementedError();
  }
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
