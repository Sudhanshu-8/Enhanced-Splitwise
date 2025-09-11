import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'settlements_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF9F506);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 64,
              backgroundImage: NetworkImage(
                "https://lh3.googleusercontent.com/aida-public/AB6AXuBj0MdZ0H6d3VAnNhxO4Yq8Pmo2UwP29fGSQ7C28GEf7VgMrii0g1DSNLhxDmf-5-2tKf6XAWPX0O4lz3Fnf8k91T2PE6iU6gF5tyK-eViUr8YubMxYswZlRaCcVQNYqB29BUIaO8E51EZ1yJ6ilB37ntsXErzMQEVmY7kTWmqG6UOz5XWnqsx6XUj98y1Ck6SiWITRT60nD83I9Fe74CK7gt9HluZZl9Ppv8YX_Pvr4kdwapTU7K2F_EETKlLJRyzql3-t7uw0_6w",
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Ethan Carter",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Joined 2021",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Settings",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Column(
                    children: [
                      _buildSwitchTile("Notifications", primaryColor),
                      const Divider(height: 1),
                      _buildOptionTile("Currency", "USD"),
                      const Divider(height: 1),
                      _buildOptionTile("Language", "English"),
                      const Divider(height: 1),
                      _buildSwitchTile("Dark Mode", primaryColor),
                    ],
                  ),
                ),
              ],
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
              _buildNavIcon(context, Icons.dashboard, "Dashboard", Colors.grey,
                      () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()));
                  }),
              _buildNavIcon(context, Icons.group, "Groups", Colors.grey, () {}),
              GestureDetector(
                onTap: () {},
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
                      )
                    ],
                  ),
                  child: const Icon(Icons.add, size: 32, color: Colors.black),
                ),
              ),
              _buildNavIcon(context, Icons.receipt_long, "Settlements", Colors.grey,
                      () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => const SettlementsScreen()));
                  }),
              _buildNavIcon(context, Icons.person, "Profile", Colors.black, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String label, Color activeColor) {
    return ListTile(
      title: Text(label),
      trailing: Switch(
        value: false,
        onChanged: (val) {},
        activeColor: activeColor,
      ),
    );
  }

  Widget _buildOptionTile(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildNavIcon(
      BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
