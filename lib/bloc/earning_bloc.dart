import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/earnings.dart';
import '../repositories/earnings_repository.dart';


// Events
abstract class EarningsEvent {}

class FetchEarnings extends EarningsEvent {
  final String ticker;

  FetchEarnings(this.ticker);
}

// States
abstract class EarningsState {}

class EarningsInitial extends EarningsState {}

class EarningsLoading extends EarningsState {}

class EarningsLoaded extends EarningsState {
  final List<Earnings> earningsData;

  EarningsLoaded(this.earningsData);
}

class EarningsError extends EarningsState {
  final String message;

  EarningsError(this.message);
}

// BLoC
class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final EarningsRepository earningsRepository;

  EarningsBloc(this.earningsRepository) : super(EarningsInitial()) {
    on<FetchEarnings>((event, emit) async {
      if (event.ticker.isEmpty) {
        emit(EarningsError('Ticker cannot be empty.'));
        return; // Exit early if the ticker is invalid
      }

      emit(EarningsLoading());
      try {
        final earningsData = await earningsRepository.fetchEarnings(event.ticker);
        emit(EarningsLoaded(earningsData));
      } catch (e) {
        emit(EarningsError(e.toString()));
      }
    });
  }
}
