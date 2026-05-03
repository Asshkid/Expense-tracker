import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text(
          "Statistics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,

        // 💱 CURRENCY TOGGLE BUTTON (ADDED)
        actions: [
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 💰 TOTAL CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Expenses",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),

                  // 💱 CURRENCY FIXED
                  Text(
                    provider.isUzs
                        ? "${provider.convert(provider.total).toStringAsFixed(0)} so'm"
                        : "\$${provider.total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // 📊 STATS ROW
            Row(
              children: [

                Expanded(
                  child: _buildStatCard(
                    "Transactions",
                    "${provider.expenses.length}",
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildStatCard(
                    "Per Day",
                    provider.expenses.isEmpty
                        ? "0"
                        : provider.isUzs
                        ? "${provider.convert(provider.averagePerDay).toStringAsFixed(0)} so'm"
                        : "\$${provider.averagePerDay.toStringAsFixed(1)}",
                    Icons.calendar_today,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Categories",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: provider.expenses.isEmpty
                  ? const Center(
                child: Text(
                  "No data yet 😴",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView(
                children: _buildCategorySummary(provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 STAT CARD
  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // 📦 CATEGORY SUMMARY
  List<Widget> _buildCategorySummary(provider) {
    Map<String, double> data = {};

    for (var e in provider.expenses) {
      data[e.category] = (data[e.category] ?? 0) + e.amount;
    }

    return data.entries.map((e) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              e.key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              provider.isUzs
                  ? "${provider.convert(e.value).toStringAsFixed(0)} so'm"
                  : "\$${e.value.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}