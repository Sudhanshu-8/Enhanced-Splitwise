import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // Import your DashboardScreen
import 'profile.dart'; // Import your ProfileScreen

class SettlementsScreen extends StatelessWidget {
  const SettlementsScreen({super.key});

  final List<Map<String, dynamic>> youOwe = const [
    {
      "name": "Liam",
      "amount": 12.50,
      "image":
      "https://lh3.googleusercontent.com/aida-public/AB6AXuDO5F5bCBbXr_w3oXgvg3BNU0X5vtQzGErEzRuMyL4QM9qtWXK9crvxf5UwUv3h_PCSqqtT37kP4PYmH9w0uf9HvwCIdTutdiijlO0Biqml42CDpoHnHBYZm85-KgOqkZjkBpnEij0EIa6L5xxeUurmyxzvOQY-6J6m4q1juoTmgcYBFXnI8bGCr-px7c_d0X_m-rLzz0B3ixzZhrMFC3BzUW-fLJEWTcgc0C_2Qv-TB0LKOrj9nU9BBxumUeEAr2W0eI0rEHo9p-Q"
    },
    {
      "name": "Sophia",
      "amount": 10.00,
      "image":
      "https://lh3.googleusercontent.com/aida-public/AB6AXuCzPz7d5ag8d-zGAnWjaU1KO48j-913dFZW-Vno9wta-vO1WqcSBEmHT384rE_objZSobvYQop22mGYnEethyA3x61bj10LIZnkn2QZhXM7NDm63dANjjpDWM2ITbJ5LWEeKnD_VZ_sMWlbynO71oRW5TJHdmMm_o70E5P5JoAJpbHRnHsxsewGEKlbAgqQ0bcglavscwt8i2-FXzyjJxe8UHCCbYSmPnGS3_jmFybPlOW8O3itzfZu0S32juOwtXgneooUYfVMN28"
    },
  ];

  final List<Map<String, dynamic>> youAreOwed = const [
    {
      "name": "Ethan",
      "amount": 15.00,
      "image":
      "https://lh3.googleusercontent.com/aida-public/AB6AXuAbVr-Fas2MRaNcEfaybKEtwYIMpFqbPZ-aPZxsWlgXQMOxSiFh1CmzaC3x7BTncZesQwW3vNtLOmFLixLfxZcu-zLBA9rnG_aYmaUBZFCocDSUohm93CCtLczO-VMAiebMsc8Eo9Nkx19zdPrZiHyiwlG5pRGsUvU1e4Np1M1NV1MLmPWBm3i-T5QJORd2A91cc1UaA2dOvvaEQ1uyvwDOOo_gVm7v1tHSGRxUxKAe9-gfVWrIgcX_0SxinQdeMmHvyY4U0j3U2wY"
    },
    {
      "name": "Olivia",
      "amount": 7.50,
      "image":
      "https://lh3.googleusercontent.com/aida-public/AB6AXuAwQDrKMk762mq_A18zLmC5tui54VF7uy-noRVEgoDEDQEvHSJoPgqIiLOfeZay7L44bziyWhgRqFWZvW1feD4X16oAZrbvPMY_YabDJWmZmmkMOPhSzYli-L7RoMzfX3hxtw-6LmWh1CAJuFOBmGw-njSr2thZuh995lYp9HT3sgRlI8dCXkSEMkGqCLB-PM8DyxrPTqE-hlMjMPDISLjxXqhi3BmxSFjVtg3y9VEAu4HeT_61XB7AIyvZ8fgy_e0Jdi9M3DUvNUM"
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF9F506);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settlements",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "You Owe",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: youOwe.map((user) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(user['image']),
                      ),
                      title: Text(user['name']),
                      subtitle: Text(
                        "You owe \$${user['amount'].toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.red),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {},
                        child: const Text("Settle"),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "You Are Owed",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: youAreOwed.map((user) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(user['image']),
                      ),
                      title: Text(user['name']),
                      subtitle: Text(
                        "Owes you \$${user['amount'].toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.green),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {},
                        child: const Text("Remind"),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 4,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon(
                  context, Icons.dashboard, "Dashboard", Colors.grey, () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DashboardScreen()));
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
              _buildNavIcon(context, Icons.receipt_long, "Settlements",
                  Colors.black, () {}),
              _buildNavIcon(context, Icons.person, "Profile", Colors.grey, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
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
