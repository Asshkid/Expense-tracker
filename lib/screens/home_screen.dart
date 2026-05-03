import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text(
          "My Expenses",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,

        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CalendarScreen()),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/stats');
            },
          ),

          IconButton(
            icon: Icon(
              provider.isUzs
                  ? Icons.currency_exchange
                  : Icons.attach_money,
            ),
            onPressed: provider.toggleCurrency,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 💰 TOTAL CARD (ONLY TOTAL)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                provider.isUzs
                    ? "${provider.convert(provider.total).toStringAsFixed(0)} so'm"
                    : "\$${provider.total.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Transactions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: provider.expenses.isEmpty
                  ? const Center(child: Text("No expenses yet 😴"))
                  : ListView.builder(
                itemCount: provider.expenses.length,
                itemBuilder: (context, index) {
                  final e = provider.expenses[index];

                  return Dismissible(
                    key: ValueKey(e.key),

                    direction: DismissDirection.endToStart,

                    onDismissed: (_) {
                      final deleted =
                      provider.deleteExpense(index);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          Text("${deleted.title} deleted"),
                          action: SnackBarAction(
                            label: "UNDO",
                            onPressed: () {
                              provider.restoreExpense(deleted);
                            },
                          ),
                        ),
                      );
                    },

                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),

                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/add',
                          arguments: {
                            'expense': e,
                            'index': index,
                          },
                        );
                      },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              children: [
                                const Icon(
                                  Icons.attach_money,
                                  color: Colors.deepPurple,
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        e.category,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Text(
                                  provider.isUzs
                                      ? "${provider.convert(e.amount).toStringAsFixed(0)} so'm"
                                      : "\$${e.amount}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // 📅 DATE UNDER EACH ITEM
                            Text(
                              _formatDate(e.date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        backgroundColor: Colors.tealAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}"
        ".${date.month.toString().padLeft(2, '0')}"
        ".${date.year}";
  }
}