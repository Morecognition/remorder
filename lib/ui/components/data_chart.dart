import 'dart:async';
import 'dart:collection';

import 'package:design_sync/design_sync.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/bloc/chart/chart_bloc.dart';

class DataChart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DataChartState();
  }

  const DataChart({super.key,
    required this.remoDataStream,
    this.colors
  });

  final Stream<RemoData> remoDataStream;
  final List<Color>? colors;
}

class _DataChartState extends State<DataChart> {
  _DataChartState();

  @override
  Widget build(BuildContext context) {
    double minY = 0;
    double maxY = 450;

    return BlocBuilder<ChartBloc, ChartState>(
      builder: ((context, state) {
        if (state is RadarState) {
          return drawRadarChart();
        } else if (state is LineState || state is ChartInitial) {
          return drawLineChart(minY, maxY);
        } else {
          return Center(
            child: Text(
              "Unhandled state: $state",
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

  Widget drawLineChart(double minY, double maxY) {
    var minX = _emgChannels[0].first.x.ceilToDouble();
    var maxX = _emgChannels[0].first.x.floorToDouble() + 7;

    return Stack(children: [
      Padding(
        padding: EdgeInsets.only(
            left: 0,
            right: 16.adaptedWidth,
            bottom: 14.adaptedHeight,
            top: 50.adaptedHeight),
        child: Transform.translate(
          offset: Offset(-5, 0),
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              minX: minX,
              maxX: maxX,
              lineTouchData: const LineTouchData(enabled: false),
              clipData: const FlClipData.all(),
              gridData: gridData,
              rangeAnnotations: const RangeAnnotations(),
              lineBarsData: [
                emgLine(0, widget.colors != null ? widget.colors![0] : Colors.red, minX + 1),
                emgLine(1, widget.colors != null ? widget.colors![1] : Colors.pink, minX + 1),
                emgLine(2, widget.colors != null ? widget.colors![2] : Colors.orange, minX + 1),
                emgLine(3, widget.colors != null ? widget.colors![3] : Colors.yellow, minX + 1),
                emgLine(4, widget.colors != null ? widget.colors![4] : Colors.green, minX + 1),
                emgLine(5, widget.colors != null ? widget.colors![5] : Colors.green.shade900, minX + 1),
                emgLine(6, widget.colors != null ? widget.colors![6] : Colors.blue, minX + 1),
                emgLine(7, widget.colors != null ? widget.colors![7] : Colors.grey, minX + 1),
              ],
              titlesData: titlesData,
              borderData: borderData,
            ),
            duration: Duration.zero,
          ),
        ),
      ),
      Transform.translate(
          offset: Offset(25, 10), child: Text("Microvolts", style: labelStyle))
    ]);
  }

  FlBorderData get borderData => FlBorderData(
    show: true,
    border: Border(
      bottom: const BorderSide(color: Colors.transparent),
      top: BorderSide(color: lineColor),
      left: const BorderSide(color: Colors.transparent),
      right: const BorderSide(color: Colors.transparent),
    ),
  );

  FlGridData get gridData => FlGridData(
    show: true,
    getDrawingHorizontalLine: (value) => FlLine(
      color: lineColor,
      strokeWidth: 1,
    ),
    getDrawingVerticalLine: (value) => FlLine(
      color: lineColor,
      strokeWidth: 1,
    ),
  );

  FlTitlesData get titlesData => FlTitlesData(
      leftTitles: AxisTitles(
          drawBelowEverything: false,
          axisNameWidget: null,
          sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, title) => Transform.translate(
                  offset: const Offset(30, -10),
                  child: Text(title.formattedValue, style: labelStyle)))),
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
      bottomTitles: AxisTitles(
          axisNameWidget: Transform.translate(
            offset: Offset(5, 0),
            child: Text(
              "Seconds",
              style: labelStyle,
            ),
          ),
          sideTitles: SideTitles(
              showTitles: true,
              maxIncluded: false,
              minIncluded: false,
              getTitlesWidget: (value, title) =>
                  Text(title.formattedValue, style: labelStyle))));

  final Color lineColor = Color(0xFFC2C8D2);
  final TextStyle labelStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12.adaptedFontSize,
      color: Color(0xFF4C5460));

  LineChartBarData emgLine(int emgIndex, Color color, double minValue) {
    return LineChartBarData(
      color: color,
      spots: _emgChannels[emgIndex].where((spot) => spot.x >= minValue).toList(), //_emgChannels[emgIndex].toList(),
      dotData: const FlDotData(show: false),
      isCurved: true,
      barWidth: 2,
    );
  }

  @override
  void initState() {
    super.initState();

    _emgChannels = List.generate(
      channels,
          (integer) {
        var queue = ListQueue<FlSpot>();
        var xvalue = -1.0;
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

  double xvalue = 0;
  double step = 0.064;

  // Number of samples to keep in the graph;
  static const int _windowSize = 110;
  // 8 is the number of EMG channels available in Remo.
  static const int channels = 8;
  late List<Queue<FlSpot>> _emgChannels;
  final _radarEntries = [
    const RadarEntry(value: 300),
    const RadarEntry(value: 50),
    const RadarEntry(value: 250),
    const RadarEntry(value: 345),
    const RadarEntry(value: 321),
    const RadarEntry(value: 347),
    const RadarEntry(value: 43),
    const RadarEntry(value: 453),
  ];

  late final StreamSubscription<RemoData> remoStreamSubscription;
}