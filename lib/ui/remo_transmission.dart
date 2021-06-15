import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';

class RemoTransmission extends StatelessWidget {
  Future<void> saveFile(String data) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.paths.first!);
      file.writeAsString(data);
    }
  }

  @override
  Widget build(BuildContext _) {
    return BlocProvider<RemoTransmissionBloc>(
      create: (_) => RemoTransmissionBloc(),
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: BlocBuilder<RemoTransmissionBloc, RemoTransmissionState>(
            builder: (builderContext, builderState) {
              if (builderState is RemoTransmissionInitial) {
                return IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    BlocProvider.of<RemoTransmissionBloc>(builderContext)
                        .add(OnStartTransmission());
                  },
                );
              } else if (builderState is TransmissionStarted) {
                return IconButton(
                  icon: Icon(Icons.stop),
                  onPressed: () {
                    BlocProvider.of<RemoTransmissionBloc>(builderContext)
                        .add(OnStopTransmission());
                  },
                );
              } else if (builderState is NewDataReceived) {
                return Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Save'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Save as'),
                    )
                  ],
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
