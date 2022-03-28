import 'dart:async';
import 'dart:collection';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/bloc/chart/chart_bloc.dart';
import 'package:wakelock/wakelock.dart';

import '../bloc/remo_file/remo_file_bloc.dart';

class RemoTransmission extends StatelessWidget {
  @override
  Widget build(BuildContext _) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocProvider<ChartBloc>(
        create: ((context) => ChartBloc()),
        child: Center(
          child: BlocBuilder<RemoBloc, RemoState>(
            builder: (builderContext, remoState) {
              if (remoState is Connected) {
                return IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    Wakelock.enable();
                    BlocProvider.of<RemoBloc>(builderContext).add(
                      OnStartTransmission(),
                    );
                  },
                );
              } else if (remoState is StartingTransmission ||
                  remoState is StoppingTransmission) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (remoState is TransmissionStarted) {
                return BlocProvider<RemoFileBloc>(
                  create: (BuildContext context) {
                    var remoFileBloc = RemoFileBloc(remoState.remoDataStream);
                    remoFileBloc.add(
                      InitRemoFiles(),
                    );
                    return remoFileBloc;
                  },
                  child: Column(
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
                            _ColorLabel(
                                color: Colors.green.shade900, text: 'Ch6'),
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
                          child: _DataChart(
                            remoDataStream: remoState.remoDataStream,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BlocConsumer<RemoFileBloc, RemoFileState>(
                            listener: ((context, state) async {
                              if (state is RemoFileInitial) {
                                BlocProvider.of<RemoFileBloc>(context).add(
                                  InitRemoFiles(),
                                );
                              } else if (state is RecordingComplete) {
                                var isSaved = await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (buildContext) {
                                    return WillPopScope(
                                      onWillPop: () async => false,
                                      child: BlocProvider.value(
                                        value: BlocProvider.of<RemoFileBloc>(
                                            context),
                                        child: _SaveDialog(),
                                      ),
                                    );
                                  },
                                );
                                if (!isSaved) {
                                  BlocProvider.of<RemoFileBloc>(context)
                                      .add(DiscardRecord());
                                }
                              }
                            }),
                            builder: (context, state) {
                              if (state is RemoFileReady) {
                                return IconButton(
                                  onPressed: () {
                                    BlocProvider.of<RemoFileBloc>(context).add(
                                      StartRecording(),
                                    );
                                  },
                                  icon: Icon(Icons.fiber_manual_record),
                                );
                              } else if (state is Recording) {
                                return IconButton(
                                  onPressed: () {
                                    BlocProvider.of<RemoFileBloc>(context).add(
                                      StopRecording(),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.fiber_manual_record,
                                    color: Colors.red,
                                  ),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.stop),
                            onPressed: () {
                              Wakelock.disable();
                              BlocProvider.of<RemoBloc>(builderContext).add(
                                OnStopTransmission(),
                              );
                            },
                          ),
                          IconButton(
                            onPressed: (() {
                              BlocProvider.of<ChartBloc>(builderContext).add(
                                SwitchChart(),
                              );
                            }),
                            icon: Icon(Icons.stacked_line_chart),
                          )
                        ],
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                );
              } else if (remoState is Disconnected) {
                return Center(
                  child: Text('Please go back and connect Remo.'),
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
    return _DataChartState();
  }

  const _DataChart({
    Key? key,
    required this.remoDataStream,
  }) : super(key: key);

  final Stream<RemoData> remoDataStream;
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
        minY = -18;
        maxY = 18;
        break;
    }

    return BlocBuilder<ChartBloc, ChartState>(
      builder: ((context, state) {
        if (state is RadarState) {
          return drawRadarChart();
        } else if (state is LineState || state is ChartInitial) {
          return drawLineChart(minY, maxY);
        } else {
          return Center(
            child: Text(
              "Unhandled state: " + state.toString(),
            ),
          );
        }
      }),
    );
    //return drawLineChart(minY, maxY);
  }

  RadarChart drawRadarChart() {
    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            dataEntries: _radarEntries,
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: const BorderSide(color: Colors.transparent),
        titlePositionPercentageOffset: 0.2,
      ),
    );
  }

  LineChart drawLineChart(double minY, double maxY) {
    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        minX: _emgChannels[0].first.x,
        maxX: _emgChannels[0].last.x,
        lineTouchData: LineTouchData(enabled: false),
        clipData: FlClipData.all(),
        gridData: FlGridData(show: true),
        rangeAnnotations: RangeAnnotations(),
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
        titlesData: FlTitlesData(
          rightTitles: SideTitles(showTitles: false),
          topTitles: SideTitles(showTitles: false),
          bottomTitles: SideTitles(showTitles: false),
        ),
        axisTitleData: FlAxisTitleData(
          leftTitle: AxisTitle(
            showTitle: true,
            titleText: 'AU',
            margin: 0,
            textAlign: TextAlign.right,
          ),
          bottomTitle: AxisTitle(
            showTitle: true,
            titleText: 'samples',
            margin: 0,
            textAlign: TextAlign.right,
          ),
        ),
      ),
      swapAnimationDuration: Duration.zero,
    );
  }

  LineChartBarData emgLine(int emgIndex, Color color) {
    return LineChartBarData(
      spots: _emgChannels[emgIndex].toList(),
      dotData: FlDotData(show: false),
      isCurved: false,
      colors: [color],
      barWidth: 2,
    );
  }

  @override
  void initState() {
    super.initState();

    _emgChannels = List.generate(
      channels,
      (int) {
        var queue = ListQueue<FlSpot>();
        var xvalue = .0;
        for (var i = 0; i < _windowSize; ++i, xvalue += step) {
          queue.add(FlSpot(xvalue, 0));
        }
        return queue;
      },
    );

    // Listening to Remo.
    remoStreamSubscription = widget.remoDataStream.listen(
      (remoData) {
        setState(
          () {
            // Adding EMG values to the chart's buffer.
            for (int i = 0; i < channels; ++i) {
              _emgChannels[i].removeFirst();
              _emgChannels[i].add(
                FlSpot(xvalue, remoData.emg[i]),
              );
              _radarEntries[i] = RadarEntry(value: remoData.emg[i]);
            }
            xvalue += step;
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    remoStreamSubscription.cancel();
  }

  _DataChartState();

  double xvalue = 0;
  double step = 0.05;

  // Number of samples to keep in the graph;
  static const int _windowSize = 100;
  // 8 is the number of EMG channels available in Remo.
  static const int channels = 8;
  late List<Queue<FlSpot>> _emgChannels;
  var _radarEntries = [
    RadarEntry(value: 300),
    RadarEntry(value: 50),
    RadarEntry(value: 250),
    RadarEntry(value: 345),
    RadarEntry(value: 321),
    RadarEntry(value: 347),
    RadarEntry(value: 43),
    RadarEntry(value: 453),
  ];

  late final StreamSubscription<RemoData> remoStreamSubscription;
}

class _SaveDialog extends StatefulWidget {
  const _SaveDialog({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SaveState();
  }
}

class _SaveState extends State<_SaveDialog> {
  String selectedFileName = "";

  final _formKey = GlobalKey<FormState>();
  static List<String> _options = List.empty(growable: true);

  _SaveState();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save record?'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Insert file name:'),
          SizedBox(height: 20),
          Container(
            width: 200,
            child: Form(
              key: _formKey,
              child: RawAutocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return _options.where((String option) {
                    return option.contains(textEditingValue.text.toLowerCase());
                  });
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    onFieldSubmitted: (String value) {
                      _options.add(value);
                      selectedFileName = value;
                      onFieldSubmitted();
                    },
                    onChanged: (String value) {
                      selectedFileName = value;
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'You need to name it';
                      }
                      return null;
                    },
                  );
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                onSelected(option);
                              },
                              child: ListTile(
                                title: Text(option),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).accentColor),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              BlocProvider.of<RemoFileBloc>(context)
                  .add(SaveRecord(selectedFileName));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('File successfully saved as $selectedFileName.csv'),
                ),
              );
              Navigator.of(context).pop(true);
            }
          },
          child: Text('Save'),
        ),
        TextButton(
          style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).accentColor),
          onPressed: () async {
            BlocProvider.of<RemoFileBloc>(context).add(DiscardRecord());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Recorded values discarded'),
              ),
            );
            Navigator.of(context).pop(false);
          },
          child: Text('Discard'),
        ),
      ],
    );
  }
}
