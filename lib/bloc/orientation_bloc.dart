import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Orientation Event
abstract class OrientationEvent {}

class ToggleOrientation extends OrientationEvent {}

class ResetOrientation extends OrientationEvent {}

class InitializeOrientation extends OrientationEvent {}

// Orientation State
abstract class OrientationState {
  final bool isLandscape;
  const OrientationState(this.isLandscape);
}

class OrientationInitial extends OrientationState {
  const OrientationInitial() : super(true);
}

class OrientationChanged extends OrientationState {
  const OrientationChanged(super.isLandscape);
}

// Orientation BLoC
class OrientationBloc extends Bloc<OrientationEvent, OrientationState> {
  OrientationBloc() : super(const OrientationInitial()) {
    on<ToggleOrientation>(_onToggleOrientation);
    on<ResetOrientation>(_onResetOrientation);
    on<InitializeOrientation>(_onInitializeOrientation);
  }

  Future<void> _onInitializeOrientation(
    InitializeOrientation event,
    Emitter<OrientationState> emit,
  ) async {
    // Set to landscape and save previous orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    emit(const OrientationChanged(true));
  }

  Future<void> _onToggleOrientation(
    ToggleOrientation event,
    Emitter<OrientationState> emit,
  ) async {
    final newIsLandscape = !state.isLandscape;
    
    if (newIsLandscape) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
    
    emit(OrientationChanged(newIsLandscape));
  }

  Future<void> _onResetOrientation(
    ResetOrientation event,
    Emitter<OrientationState> emit,
  ) async {
    // Reset to portrait and restore system UI
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await Future.delayed(const Duration(milliseconds: 100)); // Small delay to ensure orientation changes
    await SystemChrome.restoreSystemUIOverlays();
    emit(const OrientationChanged(false));
  }

  @override
  Future<void> close() async {
    // Ensure we reset orientation when bloc is closed
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.restoreSystemUIOverlays();
    return super.close();
  }
}