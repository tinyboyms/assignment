import 'dart:math';
import 'package:assignment/bloc/orientation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/earnings.dart';
import 'earnings_graph.dart';

class EarningsGraphScreen extends StatelessWidget {
  final List<Earnings> earningsData;

  const EarningsGraphScreen({super.key, required this.earningsData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrientationBloc()..add(InitializeOrientation()),
      child: BlocBuilder<OrientationBloc, OrientationState>(
        builder: (context, state) {
          // ignore: deprecated_member_use
          return WillPopScope(
            onWillPop: () async {
              await _handleBack(context);
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Earnings Graph'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _handleBack(context),
                ),
                actions: [
                  IconButton(
                      icon: Icon(
                      state.isLandscape
                          ? Icons.stay_current_portrait
                          : Icons.stay_current_landscape,
                    ),
                    onPressed: () {
                      context.read<OrientationBloc>().add(ToggleOrientation());
                    },
                  ),
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      width: max(
                        MediaQuery.of(context).size.width,
                        earningsData.length * 120.0,
                      ),
                      height: state.isLandscape
                          ? MediaQuery.of(context).size.height * 0.75
                          : MediaQuery.of(context).size.width * 0.9,
                      child: EarningsGraph(earningsData: earningsData),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleBack(BuildContext context) async {
    final bloc = context.read<OrientationBloc>();
    bloc.add(ResetOrientation());
    // Wait for orientation to reset before popping
    await Future.delayed(const Duration(milliseconds: 150));
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}