part of 'chart_bloc.dart';

@immutable
abstract class ChartState {}

class ChartInitial extends ChartState {}

class RadarState extends ChartState {}

class LineState extends ChartState {}
