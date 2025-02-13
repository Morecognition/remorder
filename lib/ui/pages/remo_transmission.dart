import 'dart:async';

import 'package:design_sync/design_sync.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/bloc/chart/chart_bloc.dart';
import 'package:remorder/ui/components/recording_button.dart';
import 'package:vector_math/vector_math.dart' show Vector3;
import 'package:wakelock_plus/wakelock_plus.dart';

import '../components/data_chart.dart';

class RemoTransmission extends StatelessWidget {
  const RemoTransmission({super.key});

  static const channelColors = [
    Color(0xFFFC7F8E),
    Color(0xFFFAA869),
    Color(0xFFE5DB80),
    Color(0xFF69C9D7),
    Color(0xFF6988D7),
    Color(0xFFC273E7),
    Color(0xFF7FD769),
    Color(0xFF34AC5D),
  ];

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF6F7FF),
        toolbarHeight: 50.adaptedHeight,
        flexibleSpace: Container(
          alignment: Alignment.bottomCenter,
          child: Row(
            children: [
              SizedBox(width: 20.adaptedWidth),
              BlocBuilder<RemoFileBloc, RemoFileState>(
                builder: (context, remoFileState) {
                  return IconButton(
                      onPressed: remoFileState is Recording ? null : () async {
                        var result = await FilePicker.platform.pickFiles(
                            type: FileType.custom, allowedExtensions: ['csv']);

                        if (result == null || result.files.single.path == null) {
                          return;
                        }

                        if (context.mounted) {
                          context
                              .read<RemoFileBloc>()
                              .add(OpenRecord(result.files.single.path!));
                          Navigator.pushNamed(context, "/playback_page").then((c) {
                            if (context.mounted) {
                              context.read<RemoFileBloc>().add(Reset());
                            }
                          });
                        }
                      },
                      icon: Image.asset("assets/folder_icon.png",
                        color: remoFileState is Recording ? Colors.grey : null));
                }
              ),
              SizedBox(width: 35.adaptedWidth),
              Text(
                "Data visualization",
                style: TextStyle(
                    color: Color(0xFF2B3A51),
                    fontSize: 20.adaptedFontSize,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6F7FF),
      body: BlocProvider<ChartBloc>(
        create: (context) => ChartBloc(),
        child: BlocBuilder<RemoBloc, RemoState>(
          builder: (builderContext, remoState) {
            if (remoState is Connected) {
              builderContext.read<RemoBloc>().add(OnStartTransmission());
            }

            if (remoState is StartingTransmission ||
                remoState is StoppingTransmission) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return BlocListener<RemoFileBloc, RemoFileState>(
              listener: (context, state) async {
                if (state is RecordingComplete) {
                  Navigator.pushNamed(context, "/save_page");
                }
              },
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 16.adaptedHeight),
                      Column(children: [
                        _buildChartButtons(),
                        SizedBox(height: 46.adaptedHeight),
                        _buildFilterButtons(),
                        SizedBox(height: 12.adaptedHeight),
                      ]),
                      Container(
                        width: 343.adaptedWidth,
                        height: 432.adaptedHeight,
                        color: Colors.white,
                        child: remoState is TransmissionStarted
                            ? DataChart(
                                remoDataStream: remoState.remoDataStream,
                                colors: channelColors,
                                key: Key("remo chart"))
                            : DataChart(
                                remoDataStream: Stream.empty(),
                                colors: channelColors,
                                key: Key("empty chart")),
                      ),
                      SizedBox(height: 15.adaptedHeight),
                      BlocBuilder<RemoFileBloc, RemoFileState>(
                          builder: (context, remoFileState) => RecordButton(
                                recording: remoFileState is Recording,
                                onRecordPressed: () => context
                                    .read<RemoFileBloc>()
                                    .add(StartRecording(
                                        remoState is TransmissionStarted
                                            ? remoState.remoDataStream
                                            : Stream.empty())),
                                onStopPressed: () => context
                                    .read<RemoFileBloc>()
                                    .add(StopRecording()),
                              )),
                    ]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChartButtons() {
    return BlocBuilder<ChartBloc, ChartState>(
      builder: (context, chartState) => Row(
        children: [
          Spacer(),
          FilledButton(
            onPressed: () => chartState is LineState
                ? null
                : context.read<ChartBloc>().add(SwitchChart()),
            style: FilledButton.styleFrom(
              fixedSize: Size(
                164.adaptedWidth,
                32.adaptedHeight,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(25.adaptedRadius))),
              backgroundColor: chartState is LineState
                  ? Theme.of(context).primaryColor
                  : const Color(0x6680D0D4),
            ),
            child: Text('Graph 1',
                style: TextStyle(
                    fontSize: 20.adaptedFontSize,
                    fontWeight: FontWeight.w700,
                    color: chartState is LineState
                        ? Colors.white
                        : const Color(0xFF2B3A51))),
          ),
          Spacer(),
          FilledButton(
            onPressed: () => chartState is RadarState
                ? null
                : context.read<ChartBloc>().add(SwitchChart()),
            style: FilledButton.styleFrom(
              fixedSize: Size(
                164.adaptedWidth,
                32.adaptedHeight,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(25.adaptedRadius))),
              backgroundColor: chartState is RadarState
                  ? Theme.of(context).primaryColor
                  : const Color(0x6680D0D4),
            ),
            child: Text('Graph 2',
                style: TextStyle(
                    fontSize: 20.adaptedFontSize,
                    fontWeight: FontWeight.w700,
                    color: chartState is RadarState
                        ? Colors.white
                        : const Color(0xFF2B3A51))),
          ),
          Spacer()
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            _ColorButton(color: channelColors[0], text: 'Ch1'),
            const Spacer(),
            _ColorButton(color: channelColors[1], text: 'Ch2'),
            const Spacer(),
            _ColorButton(color: channelColors[2], text: 'Ch3'),
            const Spacer(),
            _ColorButton(color: channelColors[3], text: 'Ch4'),
            const Spacer(),
          ],
        ),
        SizedBox(height: 12.adaptedHeight),
        Row(children: [
          const Spacer(),
          _ColorButton(color: channelColors[4], text: 'Ch5'),
          const Spacer(),
          _ColorButton(color: channelColors[5], text: 'Ch6'),
          const Spacer(),
          _ColorButton(color: channelColors[6], text: 'Ch7'),
          const Spacer(),
          _ColorButton(color: channelColors[7], text: 'Ch8'),
          const Spacer()
        ]),
      ],
    );
  }
}

RemoData _csvLineToRemoData(List<double> line) {
  return RemoData(
      emg: line.take(8).toList(),
      acceleration: Vector3(line[8], line[9], line[10]),
      angularVelocity: Vector3(line[11], line[12], line[13]),
      magneticField: Vector3(line[14], line[15], line[16]));
}

class _ColorButton extends StatelessWidget {
  const _ColorButton({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74.adaptedWidth,
      height: 32.adaptedHeight,
      child: TextButton.icon(
        onPressed: () {},
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.adaptedRadius)),
              side: BorderSide(color: Color(0xFFEDEDF5))),
          backgroundColor: Colors.white,
        ),
        label: Text(text,
            style:
                TextStyle(fontSize: 12.adaptedFontSize, color: Colors.black)),
        icon: Container(
          width: 15.adaptedWidth,
          height: 15.adaptedHeight,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
