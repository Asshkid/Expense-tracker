import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'day_details_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    final daysInMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;

    final firstDayWeekday =
        DateTime(selectedMonth.year, selectedMonth.month, 1).weekday;

    final startOffset = firstDayWeekday - 1;

    final monthTotal = _monthTotal(provider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text("Calendar"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            selectedMonth = DateTime(
                              selectedMonth.year,
                              selectedMonth.month - 1,
                            );
                          });
                        },
                      ),

                      Text(
                        "${selectedMonth.month}/${selectedMonth.year}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            selectedMonth = DateTime(
                              selectedMonth.year,
                              selectedMonth.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "\$${monthTotal.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                itemCount: daysInMonth + startOffset,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1,
                ),

                itemBuilder: (context, index) {
                  if (index < startOffset) return const SizedBox();

                  final day = index - startOffset + 1;

                  final dayExpenses = provider.expenses.where((e) =>
                  e.date.year == selectedMonth.year &&
                      e.date.month == selectedMonth.month &&
                      e.date.day == day).toList();

                  final total =
                  dayExpenses.fold(0.0, (sum, e) => sum + e.amount);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DayDetailsScreen(
                            date: DateTime(
                              selectedMonth.year,
                              selectedMonth.month,
                              day,
                            ),
                          ),
                        ),
                      );
                    },

                    child: Container(
                      decoration: BoxDecoration(
                        color: _heatColor(total),
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Stack(
                        alignment: Alignment.center,
                        children: [

                          Text(
                            "$day",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Positioned(
                            bottom: 2,
                            child: Text(
                              total > 0
                                  ? "\$${total.toStringAsFixed(0)}"
                                  : "",
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _monthTotal(provider) {
    return provider.expenses
        .where((e) =>
    e.date.month == selectedMonth.month &&
        e.date.year == selectedMonth.year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Color _heatColor(double value) {
    if (value == 0) return Colors.grey.shade200;
    if (value < 50) return Colors.green.shade200;
    if (value < 100) return Colors.orange.shade200;
    if (value < 200) return Colors.red.shade400;
    return Colors.red.shade700;
  }
}