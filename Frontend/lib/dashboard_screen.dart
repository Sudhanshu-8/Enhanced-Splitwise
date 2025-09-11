import 'package:flutter/material.dart';
import 'add_expense_screen.dart';
import 'profile.dart';
import 'settlements_screen.dart'; // Make sure this exists

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final List<Map<String, dynamic>> groups = const [
    {
      "name": "Trip to Paris",
      "status": "You owe \$20",
      "statusColor": Colors.red,
      "image":
      "https://lh3.googleusercontent.com/aida-public/AB6AXuCcgEoQibqYP9g-OS-q6a9wP2rVak0Tdwt6RNq9J7LYltHiRaY1xVP-MinNAyclkTSLNM6-T1KfpHGOMyc6lm_cMjFIU-KOuG2fRPO-J0hPkMl3zqdTb6EcGIiK0-IQPvDpj3PVzzUNrmvEcEl8RyzcqlCS3ZOyF84RwFDDqlqNB8dSPYsaGylhNreEn5ZgMzPe466fMbo-EwmiIwNulHJYVJUalwvfPMRtg4fF0N-2hv575datECIRpyPPRlNzGyIWNh66IdNewTk"
    },
    {
      "name": "Weekend Getaway",
      "status": "You are owed \$15",
      "statusColor": Colors.green,
      "image":
      "https://lh3.googleusercontent.com/aida-public/AB6AXuBXXZxRrYtLxdbHJQ5ZwbWJzjK0dWhkhClHX0Q8QGYTTsNxcNtas6j3A_1E35zaMWV3KsUsLUK5RYLz86izpFFGqbB1KzbOy5UcrxPw7OXckVcYelqdqI1TrHBYiLGeRqYK-0HB1ooKuFMWUmrJU24wiF0_1b1MvL4fYQyF1BqVJ5mCY_8TEnvQuhsUMp8g0Llfzzl6vvKkt_uPRxilBsYgcUJnO0Qd92PQ2sKUfLSAY0K27SEvzS5nGWgmMdwHhEyTXJjZ0PJQpOY"
    },
    {
      "name": "Dinner with Friends",
      "status": "You owe \$5",
      "statusColor": Colors.red,
      "image":
      "https://lh3.googleusercontent.com/aida-public/AB6AXuBAG0tDj9QXaU7a-Jr2xxIdtiEcOFsP5UNb3gJLONFmZMKEtQJeCQq_QxyuVCbAiNpFDfAsNzONHCBNh9om9V0z25e8vrCQH8aDk9RAUtZ8TzBMtf_f91EhdjAMqQedS6wi8Q_ymvHkgALvLnVMtT6XQpi2NXzEuZxSeylU9HY3_ElRxYVnFEr9v_Vw812_tQwuSnlJ_QrznqGKyzta5nuazER3ipWQrSM5pwlFwXlocgLIWZDLt1rVfiOlvcJ1v0pWicbdw3-PMk8"
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF9F506);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddExpenseScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add, color: Colors.grey),
            tooltip: "Add Expense",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              "Groups",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          group["image"],
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(group["name"]),
                      subtitle: Text(
                        group["status"],
                        style: TextStyle(color: group["statusColor"]),
                      ),
                      trailing:
                      const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 4,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomIcon(context, Icons.dashboard, "Dashboard",
                  primaryColor, null),
              _buildBottomIcon(
                  context, Icons.group, "Groups", Colors.grey, null),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddExpenseScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 32),
                ),
              ),
              _buildBottomIcon(context, Icons.receipt_long, "Settlements",
                  Colors.grey, const SettlementsScreen()),
              _buildBottomIcon(
                  context, Icons.person, "Profile", Colors.grey, const ProfileScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIcon(
      BuildContext context, IconData icon, String label, Color color, Widget? screen) {
    return GestureDetector(
      onTap: () {
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          Text(
            label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
