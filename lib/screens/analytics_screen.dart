import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _firestore = FirebaseFirestore.instance;
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  String _formatMoney(double value) {
    final formatter = NumberFormat('#,##0', 'ru');
    return formatter.format(value).replaceAll(',', ' ');
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Center(child: Text('Кіру қажет'));
    }

    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - 6);
    final weekEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('transactions')
          .where('userId', isEqualTo: _userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(weekEnd))
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Қате: ${snapshot.error}'));
        }

        final transactions = snapshot.data?.docs
                .map((doc) => TransactionModel.fromDoc(doc))
                .toList() ??
            [];

        final totalIncome = transactions
            .where((t) => t.type == TransactionType.income)
            .fold(0.0, (total, t) => total + t.amount);

        final totalExpense = transactions
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (total, t) => total + t.amount);

        final categoryExpenses = <String, double>{};
        for (final t in transactions) {
          if (t.type == TransactionType.expense) {
            final cat = t.category.trim().isEmpty ? 'Басқа' : t.category;
            categoryExpenses[cat] = (categoryExpenses[cat] ?? 0) + t.amount;
          }
        }

        final dailyData = <DateTime, double>{};
        for (int i = 6; i >= 0; i--) {
          final day = DateTime(now.year, now.month, now.day - i);
          dailyData[DateTime(day.year, day.month, day.day)] = 0.0;
        }
        for (final t in transactions) {
          final day = DateTime(t.date.year, t.date.month, t.date.day);
          if (dailyData.containsKey(day)) {
            if (t.type == TransactionType.income) {
              dailyData[day] = (dailyData[day] ?? 0) + t.amount;
            } else {
              dailyData[day] = (dailyData[day] ?? 0) - t.amount;
            }
          }
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Аналитика',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Соңғы 7 күн',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 24),

            if (transactions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.pie_chart_outline,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Әзірге деректер жоқ',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              _SummaryRow(
                income: totalIncome,
                expense: totalExpense,
                formatMoney: _formatMoney,
              ),
              const SizedBox(height: 28),

              Text(
                'Шығындар санаты бойынша',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: _buildPieSections(categoryExpenses, totalExpense),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: _buildLegend(categoryExpenses),
              ),
              const SizedBox(height: 28),

              Text(
                'Күнделікті баланс',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxBarValue(dailyData.values.toList()),
                    minY: _getMinBarValue(dailyData.values.toList()),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Colors.grey.shade800,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final value = rod.toY;
                          final sign = value >= 0 ? '+' : '';
                          return BarTooltipItem(
                            '$sign${_formatMoney(value.abs())} ₸',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const Text('0');
                            final abs = value.abs();
                            if (abs >= 1000) {
                              return Text('${(abs / 1000).toStringAsFixed(0)}к');
                            }
                            return Text(abs.toStringAsFixed(0));
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= dailyData.length) return const Text('');
                            final date = dailyData.keys.elementAt(index);
                            final label = '${date.day}.${date.month}';
                            return Text(label, style: const TextStyle(fontSize: 11));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _buildBarGroups(dailyData),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieSections(
      Map<String, double> categoryExpenses, double total) {
    if (total <= 0) return [];

    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF34C471),
      const Color(0xFF4A90E2),
      const Color(0xFFE0A83E),
      const Color(0xFFE05B49),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
    ];

    final entries = categoryExpenses.entries.toList();
    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final mapEntry = entry.value;
      final value = mapEntry.value;
      final percent = value / total;
      final color = colors[index % colors.length];
      return PieChartSectionData(
        color: color,
        value: value,
        title: '${(percent * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend(Map<String, double> categoryExpenses) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF34C471),
      const Color(0xFF4A90E2),
      const Color(0xFFE0A83E),
      const Color(0xFFE05B49),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
    ];
    final entries = categoryExpenses.entries.toList();
    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final mapEntry = entry.value;
      final color = colors[index % colors.length];
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            mapEntry.key,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxBarValue(List<double> values) {
    if (values.isEmpty) return 1000;
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    final range = max - min;
    if (range == 0) return max + 1000;
    return max + range * 0.2;
  }

  double _getMinBarValue(List<double> values) {
    if (values.isEmpty) return 0;
    final min = values.reduce((a, b) => a < b ? a : b);
    if (min >= 0) return 0;
    return min - 200;
  }

  List<BarChartGroupData> _buildBarGroups(Map<DateTime, double> dailyData) {
    final entries = dailyData.entries.toList();
    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value.value;
      final isPositive = value >= 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value.abs(),
            color: isPositive ? const Color(0xFF34C471) : const Color(0xFFE05B49),
            width: 18,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    }).toList();
  }
}

class _SummaryRow extends StatelessWidget {
  final double income;
  final double expense;
  final String Function(double) formatMoney;

  const _SummaryRow({
    required this.income,
    required this.expense,
    required this.formatMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.north_east, color: const Color(0xFF34C471), size: 18),
                    const SizedBox(width: 6),
                    Text('Табыс', style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '+${formatMoney(income)} ₸',
                  style: const TextStyle(
                    color: Color(0xFF34C471),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFCEAE7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.south_east, color: const Color(0xFFE05B49), size: 18),
                    const SizedBox(width: 6),
                    Text('Шығын', style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '-${formatMoney(expense)} ₸',
                  style: const TextStyle(
                    color: Color(0xFFE05B49),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}