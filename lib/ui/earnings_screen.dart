import 'package:assignment/bloc/earning_bloc.dart';
import 'package:assignment/ui/earnings_graph_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/earnings_repository.dart';

class EarningsScreen extends StatefulWidget {
  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final TextEditingController _controller = TextEditingController();

@override
void initState() {
  super.initState();
  // Ensure keyboard settings are properly set for text input
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.restoreSystemUIOverlays();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Earnings Calendar')),
      body: BlocProvider(
        create: (context) => EarningsBloc(EarningsRepository()),
        child: BlocBuilder<EarningsBloc, EarningsState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        final ticker = _controller.text.trim();
                        if (ticker.isNotEmpty) {
                          context.read<EarningsBloc>().add(FetchEarnings(ticker));
                        }
                      },
                      child: state is EarningsLoading
                          ? CircularProgressIndicator(color: const Color.fromARGB(255, 134, 37, 246))
                          : Text('Fetch Earnings'),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (state is EarningsError) 
                    Center(child: Text(state.message, style: TextStyle(color: Colors.red))),
                  if (state is EarningsLoaded) 
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.earningsData.length,
                        itemBuilder: (context, index) {
                          final earnings = state.earningsData[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date: ${earnings.priceDate}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  SizedBox(height: 8),
                                  Text('Ticker: ${earnings.ticker}'),
                                  SizedBox(height: 8),
                                  Text('Actual EPS: ${earnings.actualEps?.toString() ?? "N/A"}'),
                                  SizedBox(height: 8),
                                  Text('Estimated EPS: ${earnings.estimatedEps?.toString() ?? "N/A"}'),
                                  SizedBox(height: 8),
                                  Text('Actual Revenue: \$${earnings.actualRevenue?.toStringAsFixed(2) ?? "N/A"}'),
                                  SizedBox(height: 8),
                                  Text('Estimated Revenue: \$${earnings.estimatedRevenue?.toStringAsFixed(2) ?? "N/A"}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (state is EarningsLoaded) 
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EarningsGraphScreen(earningsData: state.earningsData),
                              ),
                            );
                          },
                          child: Text('Generate Graph'),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}