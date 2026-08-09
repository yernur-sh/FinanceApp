import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';

enum TimeFilter { week, month, year }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _firestore = FirebaseFirestore.instance;
  TimeFilter _selectedFilter = TimeFilter.week;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  String _formatMoney(double value) {
    final formatter = NumberFormat('#,##0', 'ru');
    return formatter.format(value).replaceAll(',', ' ');
  }

  DateTimeRange _getFilterRange() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case TimeFilter.week:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day - 6),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case TimeFilter.month:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case TimeFilter.year:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31, 23, 59, 59),
        );
    }
  }

  final List<Color> _chartColors = const [
    Color(0xFF4C86FF),
    Color(0xFF35E0A0),
    Color(0xFF7FA8FF),
    Color(0xFFFFB84D),
    Color(0xFFFF6B62),
    Color(0xFFC98BFF),
    Color(0xFF3FD3E8),
  ];

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Center(
          child: Text('Кіру қажет', style: appBody(color: kTextSecondary)));
    }

    final range = _getFilterRange();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('transactions')
          .where('userId', isEqualTo: _userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(range.end))
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kAccent));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Қате: ${snapshot.error}',
                  style: appBody(color: kTextSecondary)));
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
        if (_selectedFilter == TimeFilter.week) {
          for (int i = 6; i >= 0; i--) {
            final day = DateTime(range.end.year, range.end.month, range.end.day - i);
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
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Аналитика', style: appDisplay(fontSize: 24, fontWeight: FontWeight.w700)),
                _buildFilterSegment(),
              ],
            ),
            const SizedBox(height: 20),

            _SummaryRow(
              income: totalIncome,
              expense: totalExpense,
              formatMoney: _formatMoney,
            ),
            const SizedBox(height: 24),

            if (transactions.isEmpty)
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 48),
                radius: 24,
                child: Column(
                  children: [
                    const Icon(Icons.pie_chart_outline, size: 56, color: kTextMuted),
                    const SizedBox(height: 12),
                    Text(
                      'Тандалған уақыт аралығында деректер жоқ',
                      style: appBody(color: kTextMuted, fontSize: 14),
                    ),
                  ],
                ),
              )
            else ...[
              _InteractiveCategoryExpenses(
                categoryExpenses: categoryExpenses,
                totalExpense: totalExpense,
                chartColors: _chartColors,
                formatMoney: _formatMoney,
              ),

              if (_selectedFilter == TimeFilter.week) ...[
                const SizedBox(height: 24),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  radius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Күнделікті Баланс Динамикасы',
                        style: appBody(
                            fontSize: 16, fontWeight: FontWeight.w700, color: kTextPrimary),
                      ),
                      const SizedBox(height: 20),
                      Builder(builder: (context) {
                        final rawValues = dailyData.values.toList();
                        final interval = _niceInterval(rawValues);
                        final maxY = _getMaxBarValue(rawValues, interval);
                        final minY = _getMinBarValue(rawValues, interval);

                        return Container(
                          padding: const EdgeInsets.fromLTRB(4, 14, 14, 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.035),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kBorder),
                          ),
                          child: SizedBox(
                            height: 190,
                            child: BarChart(
                              BarChartData(
                                backgroundColor: Colors.transparent,
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxY,
                                minY: minY,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipColor: (group) => kSurface,
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
                                  topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 34,
                                      interval: interval,
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: SizedBox(
                                            width: 30,
                                            child: Text(
                                              _compactAxisLabel(value),
                                              textAlign: TextAlign.right,
                                              style: appBody(fontSize: 9.5, color: kTextMuted),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 26,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index < 0 || index >= dailyData.length) {
                                          return const Text('');
                                        }
                                        final date = dailyData.keys.elementAt(index);
                                        final label = '${date.day}.${date.month}';
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(label,
                                              style: appBody(fontSize: 10, color: kTextMuted)),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: interval,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: value == 0
                                        ? Colors.white.withOpacity(0.16)
                                        : kAccent.withOpacity(0.09),
                                    strokeWidth: 1,
                                  ),
                                ),
                                barGroups: _buildBarGroups(dailyData),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildFilterSegment() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: TimeFilter.values.map((filter) {
          final isSelected = _selectedFilter == filter;
          String label;
          switch (filter) {
            case TimeFilter.week:
              label = 'Апта';
              break;
            case TimeFilter.month:
              label = 'Ай';
              break;
            case TimeFilter.year:
              label = 'Жыл';
              break;
          }
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected ? kAccentGradient : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: appBody(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : kTextMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  double _niceInterval(List<double> values) {
    final maxAbs = values.isEmpty
        ? 0.0
        : values.map((v) => v.abs()).reduce((a, b) => a > b ? a : b);
    final target = (maxAbs <= 0 ? 5000 : maxAbs) / 4;
    final magnitude =
    math.pow(10, (math.log(target) / math.ln10).floor()).toDouble();
    final residual = target / magnitude;
    double niceResidual;
    if (residual < 1.5) {
      niceResidual = 1;
    } else if (residual < 3) {
      niceResidual = 2;
    } else if (residual < 7) {
      niceResidual = 5;
    } else {
      niceResidual = 10;
    }
    return niceResidual * magnitude;
  }

  double _getMaxBarValue(List<double> values, double interval) {
    if (values.isEmpty) return interval;
    final max = values.reduce((a, b) => a > b ? a : b);
    if (max <= 0) return interval;
    var top = (max / interval).ceil() * interval;
    if (top <= max) top += interval;
    return top;
  }

  double _getMinBarValue(List<double> values, double interval) {
    if (values.isEmpty) return 0;
    final min = values.reduce((a, b) => a < b ? a : b);
    if (min >= 0) return 0;
    var bottom = (min / interval).floor() * interval;
    if (bottom >= min) bottom -= interval;
    return bottom;
  }

  String _compactAxisLabel(double value) {
    if (value == 0) return '0';
    final abs = value.abs();
    final sign = value < 0 ? '-' : '';
    if (abs >= 1000000) {
      return '$sign${(abs / 1000000).toStringAsFixed(abs % 1000000 == 0 ? 0 : 1)}М';
    }
    if (abs >= 1000) {
      return '$sign${(abs / 1000).toStringAsFixed(0)}к';
    }
    return '$sign${abs.toStringAsFixed(0)}';
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
            color: isPositive ? kGreen : kClay,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }
}

// -----------------------------------------------------------------------------
// ИНТЕРАКТИВНАЯ ДИАГРАММА ПО КАТЕГОРИЯМ
// -----------------------------------------------------------------------------
class _InteractiveCategoryExpenses extends StatefulWidget {
  final Map<String, double> categoryExpenses;
  final double totalExpense;
  final List<Color> chartColors;
  final String Function(double) formatMoney;

  const _InteractiveCategoryExpenses({
    required this.categoryExpenses,
    required this.totalExpense,
    required this.chartColors,
    required this.formatMoney,
  });

  @override
  State<_InteractiveCategoryExpenses> createState() => _InteractiveCategoryExpensesState();
}

class _InteractiveCategoryExpensesState extends State<_InteractiveCategoryExpenses> {
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final entries = widget.categoryExpenses.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    final hasExpenses = widget.totalExpense > 0 && entries.isNotEmpty;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Шығындар санаты бойынша',
            style: appBody(fontSize: 16, fontWeight: FontWeight.w700, color: kTextPrimary),
          ),
          const SizedBox(height: 20),

          if (!hasExpenses)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.monetization_on_outlined, size: 48, color: kTextMuted),
                    const SizedBox(height: 8),
                    Text(
                      'Бұл мерзімде шығындар тіркелмеген',
                      style: appBody(color: kTextMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null ||
                          !hasExpenses) {
                        if (_touchedPieIndex != -1) {
                          setState(() {
                            _touchedPieIndex = -1;
                          });
                        }
                        return;
                      }

                      final newIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;

                      if (_touchedPieIndex != newIndex) {
                        setState(() {
                          _touchedPieIndex = newIndex;
                        });
                      }
                    },
                  ),
                  sectionsSpace: 3,
                  centerSpaceRadius: 50,
                  sections: _buildSections(entries),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(height: 1, color: Colors.white.withOpacity(0.08)),
            const SizedBox(height: 16),
            ..._buildCategoryList(entries),
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(List<MapEntry<String, double>> entries) {
    if (widget.totalExpense <= 0) return [];

    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value.value;
      final isTouched = index == _touchedPieIndex;
      final radius = isTouched ? 48.0 : 45.0;
      final color = widget.chartColors[index % widget.chartColors.length];

      return PieChartSectionData(
        color: color,
        value: value,
        showTitle: false,
        radius: radius,
      );
    }).toList();
  }

  List<Widget> _buildCategoryList(List<MapEntry<String, double>> entries) {
    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final mapEntry = entry.value;
      final percent =
      widget.totalExpense > 0 ? (mapEntry.value / widget.totalExpense) : 0.0;
      final color = widget.chartColors[index % widget.chartColors.length];

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      mapEntry.key,
                      style: appBody(
                          fontWeight: FontWeight.w600, fontSize: 14, color: kTextPrimary),
                    ),
                  ],
                ),
                Text(
                  '${widget.formatMoney(mapEntry.value)} ₸ (${(percent * 100).toStringAsFixed(1)}%)',
                  style: appBody(
                      fontWeight: FontWeight.w600, fontSize: 13, color: kTextSecondary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.white.withOpacity(0.06),
                color: color,
                minHeight: 6,
              ),
            ),
          ],
        ),
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
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            radius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: kGreenBg, shape: BoxShape.circle),
                      child: const Icon(Icons.north_east, color: kGreen, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text('Табыс',
                        style: appBody(
                            color: kTextSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '+${formatMoney(income)} ₸',
                  style: appBody(color: kGreen, fontWeight: FontWeight.w700, fontSize: 17),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            radius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: kClayBg, shape: BoxShape.circle),
                      child: const Icon(Icons.south_east, color: kClay, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text('Шығын',
                        style: appBody(
                            color: kTextSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '-${formatMoney(expense)} ₸',
                  style: appBody(color: kClay, fontWeight: FontWeight.w700, fontSize: 17),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}