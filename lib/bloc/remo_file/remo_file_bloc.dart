import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

part 'remo_file_event.dart';
part 'remo_file_state.dart';

class RemoFileBloc extends Bloc<RemoFileEvent, RemoFileState> {
  RemoFileBloc(this.remoDataStream) : super(RemoFileInitial()) {
    on<InitRemoFiles>(_init);
    on<StartRecording>(_startRecording);
    on<StopRecording>(_stopRecording);
    on<DiscardRecord>(_discardRecord);
    on<SaveRecord>(_saveRecord);
  }

  void _init(InitRemoFiles event, Emitter<RemoFileState> emit) async {
    tmpDirectory = await getTemporaryDirectory();
    var directory = await getExternalStorageDirectory();
    if (directory == null) {
      emit(RemoFileInitError());
    } else {
      externalStorageDirectory = directory;
      tmpFilePath = tmpDirectory.path + '/$tmpFileName.csv';
      emit(RemoFileReady());
    }
  }

  void _startRecording(StartRecording event, Emitter<RemoFileState> emit) {
    File tmpCsvFile = File(tmpFilePath);
    fileSink = tmpCsvFile.openWrite();
    remoStreamSubscription = remoDataStream.listen(
      (remoData) {
        fileSink.write(remoData.toCsvString());
      },
    );
    emit(Recording());
  }

  void _stopRecording(StopRecording event, Emitter<RemoFileState> emit) {
    remoStreamSubscription.cancel();
    fileSink.close();
    emit(RecordingComplete());
  }

  void _discardRecord(DiscardRecord event, Emitter<RemoFileState> emit) {
    emit(RecordDiscarded());
    emit(RemoFileReady());
  }

  void _saveRecord(SaveRecord event, Emitter<RemoFileState> emit) async {
    final String newFilePath =
        externalStorageDirectory.path + '/${event.fileName}.csv';
    File tmpFile = File(tmpFilePath);
    File newFile = await tmpFile.copy(newFilePath);
    emit(RecordSaved(newFile));
    emit(RemoFileReady());
  }

  final Stream<RemoData> remoDataStream;
  late StreamSubscription<RemoData> remoStreamSubscription;
  late IOSink fileSink;
  late String tmpFilePath;
  late final Directory tmpDirectory;
  late final Directory externalStorageDirectory;
  final String tmpFileName = 'tmpFileName';
}
