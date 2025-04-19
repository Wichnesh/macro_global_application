import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/project/ProjectBloc.dart';
import '../blocs/project/ProjectEvent.dart';
import '../blocs/project/ProjectState.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<ProjectBloc>(context)..add(LoadProjects()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Project Comparison')),
        body: BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, state) {
            if (state is ProjectLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProjectLoaded) {
              final projects = state.projects;

              if (projects.length < 3) {
                return const Center(child: Text('Need at least 3 projects to compare.'));
              }

              final data = projects.map((p) {
                final revenue = p.projectedRevenue.values.map((v) => (v as num).toDouble()).fold(0.0, (a, b) => a + b);
                final profitPercent = revenue > 0 ? ((revenue * 0.3) / revenue) * 100 : 0;

                return {
                  'name': p.name,
                  'people': p.peopleWorking.toDouble(),
                  'revenue': revenue,
                  'profit': profitPercent,
                };
              }).toList();

              final colorList = [Colors.red, Colors.green, Colors.blue];

              final totalPeople = data.fold(0.0, (sum, item) => sum + (item['people'] as double));
              final totalRevenue = data.fold(0.0, (sum, item) => sum + (item['revenue'] as double));
              final totalProfit = data.fold(0.0, (sum, item) => sum + (item['profit'] as double));

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Bar Chart (People, Revenue, Profit %)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          barGroups: List.generate(data.length, (i) {
                            return BarChartGroupData(x: i, barRods: [
                              BarChartRodData(toY: data[i]['people'] as double, width: 6, color: Colors.blue),
                              BarChartRodData(toY: (data[i]['revenue'] as double) / 1000, width: 6, color: Colors.green),
                              BarChartRodData(toY: data[i]['profit'] as double, width: 6, color: Colors.orange),
                            ]);
                          }),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 && value.toInt() < data.length) {
                                    return Text(
                                      data[value.toInt()]['name'].toString().split(' ').first,
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          barTouchData: BarTouchData(enabled: true),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1),
                    const SizedBox(height: 10),

                    // Pie Chart: People
                    const Text('👥 People Distribution'),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: List.generate(data.length, (i) {
                            final value = data[i]['people'] as double;
                            final percent = totalPeople == 0 ? 0 : (value / totalPeople * 100);
                            final name = data[i]['name'].toString().split(' ').first;

                            return PieChartSectionData(
                              value: value,
                              title: '$name - ${percent.toStringAsFixed(1)}%',
                              color: colorList[i % colorList.length],
                              titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                              radius: 70,
                            );
                          }),
                          centerSpaceRadius: 30,
                          sectionsSpace: 3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pie Chart: Revenue
                    const Text('💰 Revenue Distribution'),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: List.generate(data.length, (i) {
                            final value = data[i]['revenue'] as double;
                            final percent = totalRevenue == 0 ? 0 : (value / totalRevenue * 100);
                            final name = data[i]['name'].toString().split(' ').first;
                            return PieChartSectionData(
                              value: value,
                              title: '$name - ${percent.toStringAsFixed(1)}%',
                              color: colorList[i % colorList.length],
                              titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
                              radius: 70,
                            );
                          }),
                          centerSpaceRadius: 30,
                          sectionsSpace: 3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pie Chart: Profit %
                    const Text('📈 Profit % Comparison'),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: List.generate(data.length, (i) {
                            final value = data[i]['profit'] as double;
                            final percent = totalProfit == 0 ? 0 : (value / totalProfit * 100);
                            final name = data[i]['name'].toString().split(' ').first;
                            return PieChartSectionData(
                              value: value,
                              title: '$name - ${percent.toStringAsFixed(1)}%',
                              color: colorList[i % colorList.length],
                              titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
                              radius: 70,
                            );
                          }),
                          centerSpaceRadius: 30,
                          sectionsSpace: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('Failed to load chart data.'));
            }
          },
        ),
      ),
    );
  }
}
