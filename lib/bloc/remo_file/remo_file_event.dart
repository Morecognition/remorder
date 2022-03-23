part of 'remo_file_bloc.dart';

@immutable
abstract class RemoFileEvent {}

class InitRemoFiles extends RemoFileEvent {}

class StartRecording extends RemoFileEvent {}

class StopRecording extends RemoFileEvent {}

class SaveRecord extends RemoFileEvent {
  SaveRecord(this.fileName);
  final String fileName;
}

class DiscardRecord extends RemoFileEvent {}
