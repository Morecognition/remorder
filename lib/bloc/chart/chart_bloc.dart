import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'chart_event.dart';
part 'chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  ChartBloc() : super(LineState()) {
    on<SwitchChart>(
      (event, emit) {
        switch (_chartTypes) {
          case ChartTypes.lineChart:
            _chartTypes = ChartTypes.radarChart;
            emit(RadarState());
            break;
          case ChartTypes.radarChart:
            _chartTypes = ChartTypes.lineChart;
            emit(LineState());
            break;
        }
      },
    );
  }

  ChartTypes _chartTypes = ChartTypes.lineChart;
}

enum ChartTypes { lineChart, radarChart }
