import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/orientation_bloc.dart';
import '../models/earnings.dart';
import 'transcript_screen.dart';

class EarningsGraph extends StatelessWidget {
  final List<Earnings> earningsData;

  const EarningsGraph({super.key, required this.earningsData});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrientationBloc, OrientationState>(
      builder: (context, state) {
        return Column(
          children: [
            // Legend
            Padding(
              padding: EdgeInsets.only(bottom: state.isLandscape ? 16.0 : 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Actual EPS', Colors.blue),
                  const SizedBox(width: 20),
                  _buildLegendItem('Estimated EPS', Colors.orange),
                ],
              ),
            ),
            // Graph
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LineChart(
                  LineChartData(
                    minX: -0.5,
                    maxX: earningsData.length - 0.5,
                    minY: _calculateMinY(),
                    maxY: _calculateMaxY(),
                    clipData: const FlClipData.all(),
                    titlesData: _buildTitlesData(state),
                    gridData: _buildGridData(),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                          color: const Color.fromARGB(255, 212, 193, 193)
                              .withOpacity(0.5)),
                    ),
                    lineBarsData: [
                      _buildActualEpsLine(context),
                      _buildEstimatedEpsLine(),
                    ],
                    // Update the lineTouchData section
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        //tooltipBgColor: Colors.white.withOpacity(0.9),
                        tooltipPadding: const EdgeInsets.all(8),
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            final isActualEps =
                                spot.barIndex == 0; // First line is Actual EPS
                            final value = spot.y;

                            // Format the number without trailing zeros
                            String formattedValue = value.toString();
                            if (formattedValue.contains('.')) {
                              formattedValue =
                                  formattedValue.replaceAll(RegExp(r'0*$'), '');
                              formattedValue =
                                  formattedValue.replaceAll(RegExp(r'\.$'), '');
                            }

                            return LineTooltipItem(
                              '${isActualEps ? 'Actual' : 'Estimated'} EPS: \$$formattedValue',
                              TextStyle(
                                color:
                                    isActualEps ? Colors.blue : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                      handleBuiltInTouches: true,
                      touchCallback:
                          (FlTouchEvent event, LineTouchResponse? response) {
                        if (event is FlTapUpEvent &&
                            response?.lineBarSpots != null &&
                            response!.lineBarSpots!.isNotEmpty) {
                          final spot = response.lineBarSpots!.first;
                          final index = spot.x.toInt();
                          final earnings = earningsData[index];

                          // Parse the date to get quarter and year
                          final date = DateTime.parse(earnings.priceDate);
                          final quarter = ((date.month - 1) ~/ 3 + 1)
                              .toString(); // Calculate quarter (1-4)
                          final year = date.year.toString();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TranscriptScreen(
                                ticker: earnings.ticker,
                                year: year,
                                quarter: quarter,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Build titles data for the graph
  FlTitlesData _buildTitlesData(OrientationState state) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: state.isLandscape ? 80 : 60,
          interval: 1,
          getTitlesWidget: _buildQuarterTitle,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 65,
          interval: _calculateYAxisInterval(),
          getTitlesWidget: (value, meta) => _buildYAxisLabel(value, state),
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  // Build grid data for the graph
  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: _calculateYAxisInterval(),
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) => FlLine(
        color: Colors.grey.withOpacity(0.3),
        strokeWidth: 1,
      ),
      getDrawingVerticalLine: (value) => FlLine(
        color: Colors.grey.withOpacity(0.3),
        strokeWidth: 1,
      ),
    );
  }

  // Build actual EPS line
  LineChartBarData _buildActualEpsLine(BuildContext context) {
    return LineChartBarData(
      spots: _getActualEpsData(),
      isCurved: true,
      color: Colors.blue,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 6,
            color: Colors.blue,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  // Build estimated EPS line
  LineChartBarData _buildEstimatedEpsLine() {
    return LineChartBarData(
      spots: _getEstimatedEpsData(),
      isCurved: true,
      color: Colors.orange,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 6,
            color: Colors.orange,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  // Build Y-axis label
  Widget _buildYAxisLabel(double value, OrientationState state) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Text(
        _formatYAxisLabel(value),
        style: TextStyle(
          fontSize: state.isLandscape ? 11 : 10,
          color: Colors.black87,
        ),
        maxLines: 1,
      ),
    );
  }

  // Build legend item
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // Calculate Y-axis interval
  double _calculateYAxisInterval() {
    double range = _calculateMaxY() - _calculateMinY();
    if (range <= 1) return 0.2;
    if (range <= 5) return 0.5;
    if (range <= 10) return 1.0;
    if (range <= 100) return range / 10;
    return range / 8;
  }

  // Calculate minimum Y value
  double _calculateMinY() {
    double minValue = double.infinity;
    for (final earnings in earningsData) {
      final actualEps = earnings.actualEps ?? double.infinity;
      final estimatedEps = earnings.estimatedEps ?? double.infinity;
      minValue = min(minValue, min(actualEps, estimatedEps));
    }
    return minValue - (minValue.abs() * 0.1);
  }

  // Calculate maximum Y value
  double _calculateMaxY() {
    double maxValue = double.negativeInfinity;
    for (final earnings in earningsData) {
      final actualEps = earnings.actualEps ?? double.negativeInfinity;
      final estimatedEps = earnings.estimatedEps ?? double.negativeInfinity;
      maxValue = max(maxValue, max(actualEps, estimatedEps));
    }
    return maxValue + (maxValue.abs() * 0.1);
  }

  // Format Y-axis label
  String _formatYAxisLabel(double value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(2);
  }

  // Get actual EPS data points
  List<FlSpot> _getActualEpsData() {
    return earningsData.asMap().entries.map((entry) {
      final index = entry.key;
      final earnings = entry.value;
      final actualEps = earnings.actualEps ?? 0;
      return FlSpot(index.toDouble(), actualEps);
    }).toList();
  }

  // Get estimated EPS data points
  List<FlSpot> _getEstimatedEpsData() {
    return earningsData.asMap().entries.map((entry) {
      final index = entry.key;
      final earnings = entry.value;
      final estimatedEps = earnings.estimatedEps ?? 0;
      return FlSpot(index.toDouble(), estimatedEps);
    }).toList();
  }

// Update the _buildQuarterTitle method to be consistent
  Widget _buildQuarterTitle(double value, TitleMeta meta) {
    if (value.toInt() >= 0 && value.toInt() < earningsData.length) {
      final earnings = earningsData[value.toInt()];
      final date = DateTime.parse(earnings.priceDate);
      final quarter = _getQuarterFromDate(date);

      String range;
      switch (quarter) {
        case '1':
          range = 'Jan-Mar';
          break;
        case '2':
          range = 'Apr-Jun';
          break;
        case '3':
          range = 'Jul-Sep';
          break;
        case '4':
          range = 'Oct-Dec';
          break;
        default:
          range = '';
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Q$quarter',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            range,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }
    return const Text('');
  }

  String _getQuarterFromDate(DateTime date) {
    switch ((date.month - 1) ~/ 3) {
      case 0:
        return '1'; // Jan-Mar
      case 1:
        return '2'; // Apr-Jun
      case 2:
        return '3'; // Jul-Sep
      case 3:
        return '4'; // Oct-Dec
      default:
        return '1';
    }
  }
}
