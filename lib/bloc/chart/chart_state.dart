part of 'chart_bloc.dart';

@immutable
abstract class ChartState {}

class ChartInitial extends ChartState {}

class RadarChart extends ChartState {}

class LineChart extends ChartState {}
