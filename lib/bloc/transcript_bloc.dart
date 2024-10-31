import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/transcript.dart';
import '../services/transcript_service.dart';

// Events
abstract class TranscriptEvent {}

class FetchTranscript extends TranscriptEvent {
  final String ticker;
  final String year;
  final String quarter;

  FetchTranscript({
    required this.ticker,
    required this.year,
    required this.quarter,
  });
}

// States
abstract class TranscriptState {}

class TranscriptInitial extends TranscriptState {}

class TranscriptLoading extends TranscriptState {
  final String ticker;
  final String year;
  final String quarter;

  TranscriptLoading({
    required this.ticker,
    required this.year,
    required this.quarter,
  });
}

class TranscriptLoaded extends TranscriptState {
  final TranscriptModel transcript;
  final bool isEmpty;

  TranscriptLoaded(this.transcript)
      : isEmpty = transcript.content.startsWith('No transcript');
}

class TranscriptError extends TranscriptState {
  final String message;
  final String ticker;
  final String year;
  final String quarter;
  final ErrorType errorType;

  TranscriptError({
    required this.message,
    required this.ticker,
    required this.year,
    required this.quarter,
    this.errorType = ErrorType.unknown,
  });
}

enum ErrorType {
  notFound,
  rateLimit,
  apiKey,
  network,
  unknown,
}

class TranscriptBloc extends Bloc<TranscriptEvent, TranscriptState> {
  final TranscriptService _service = TranscriptService();

  TranscriptBloc() : super(TranscriptInitial()) {
    on<FetchTranscript>(_onFetchTranscript);
  }

  Future<void> _onFetchTranscript(
    FetchTranscript event,
    Emitter<TranscriptState> emit,
  ) async {
    emit(TranscriptLoading(
      ticker: event.ticker,
      year: event.year,
      quarter: event.quarter,
    ));

    try {
      final transcript = await _service.getTranscript(
        ticker: event.ticker,
        year: event.year,
        quarter: event.quarter,
      );

      // Check for empty response
      if (transcript.content.isEmpty || transcript.content == '[]') {
        emit(TranscriptError(
          message: 'No transcript available for this quarter',
          ticker: event.ticker,
          year: event.year,
          quarter: event.quarter,
          errorType: ErrorType.notFound,
        ));
        return;
      }

      emit(TranscriptLoaded(transcript));
    } catch (e) {
      String message;
      ErrorType errorType;

      if (e.toString().contains('404') ||
          e.toString().contains('empty response')) {
        message = 'No transcript available for this quarter';
        errorType = ErrorType.notFound;
      } else if (e.toString().contains('429')) {
        message = 'Too many requests. Please try again later.';
        errorType = ErrorType.rateLimit;
      } else if (e.toString().contains('403')) {
        message = 'API key invalid or expired';
        errorType = ErrorType.apiKey;
      } else if (e.toString().contains('SocketException')) {
        message = 'Network connection error';
        errorType = ErrorType.network;
      } else {
        print('Error details: $e'); // For debugging
        message = 'No transcript available for this quarter';
        errorType = ErrorType.notFound;
      }

      emit(TranscriptError(
        message: message,
        ticker: event.ticker,
        year: event.year,
        quarter: event.quarter,
        errorType: errorType,
      ));
    }
  }
}
