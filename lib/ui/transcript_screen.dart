import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transcript_bloc.dart';

class TranscriptScreen extends StatelessWidget {
  final String ticker;
  final String year;
  final String quarter;

  const TranscriptScreen({
    Key? key,
    required this.ticker,
    required this.year,
    required this.quarter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TranscriptBloc()
        ..add(FetchTranscript(
          ticker: ticker,
          year: year,
          quarter: quarter,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: Text('$ticker Q$quarter $year Transcript'),
        ),
        body: BlocBuilder<TranscriptBloc, TranscriptState>(
          builder: (context, state) {
            if (state is TranscriptLoading) {
              return _buildLoadingState(state);
            } else if (state is TranscriptLoaded) {
              return _buildLoadedState(context, state);
            } else if (state is TranscriptError) {
              return _buildErrorState(context, state);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(TranscriptLoading state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading Q${state.quarter} ${state.year} transcript...',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, TranscriptLoaded state) {
    if (state.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              state.transcript.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$ticker Q$quarter $year Earnings Call Transcript',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            state.transcript.content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, TranscriptError state) {
    IconData iconData;
    Color iconColor;

    switch (state.errorType) {
      case ErrorType.notFound:
        iconData = Icons.search_off;
        iconColor = Colors.orange;
        break;
      case ErrorType.rateLimit:
        iconData = Icons.timer_off;
        iconColor = Colors.red;
        break;
      case ErrorType.apiKey:
        iconData = Icons.key_off;
        iconColor = Colors.red;
        break;
      case ErrorType.network:
        iconData = Icons.wifi_off;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.error_outline;
        iconColor = Colors.red;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, color: iconColor, size: 60),
          const SizedBox(height: 16),
          Text(
            state.message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<TranscriptBloc>().add(
                FetchTranscript(
                  ticker: state.ticker,
                  year: state.year,
                  quarter: state.quarter,
                ),
              );
            },
            child: const Text('Retry'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}