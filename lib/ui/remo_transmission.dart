import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:path_provider/path_provider.dart';

class RemoTransmission extends StatelessWidget {
  Future<void> saveFile(String data) async {}

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
                return _SavePrompt(remoData: builderState.data);
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
