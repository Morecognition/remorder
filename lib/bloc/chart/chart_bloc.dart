import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'chart_event.dart';
part 'chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  ChartBloc() : super(ChartInitial()) {
    on<SwitchChart>(
      (event, emit) {
        switch (_chartTypes) {
          case ChartTypes.LineChart:
            _chartTypes = ChartTypes.RadarChart;
            emit(RadarState());
            break;
          case ChartTypes.RadarChart:
            _chartTypes = ChartTypes.LineChart;
            emit(LineState());
            break;
        }
      },
    );
  }

  ChartTypes _chartTypes = ChartTypes.LineChart;
}

enum ChartTypes { LineChart, RadarChart }
