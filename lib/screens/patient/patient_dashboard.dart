import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medinotesapp/screens/auth/login_screen.dart'; // <-- Import your login screen

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // clear all saved data (tokens, ids, etc.)

    // Navigate to Login and clear stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        title: const Text("Patient Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Logout"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, Bhagirath",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Here’s your health overview",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Upcoming Appointments
            _buildDashboardCard(
              context,
              title: "Upcoming Appointment",
              subtitle: "Dr. Smith • 10 Oct, 3:00 PM",
              icon: Icons.calendar_today,
              color: Colors.blue,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            // Medical Records
            _buildDashboardCard(
              context,
              title: "Medical Records",
              subtitle: "Lab reports, scans & history",
              icon: Icons.folder_open,
              color: Colors.orange,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            // Prescriptions
            _buildDashboardCard(
              context,
              title: "Prescriptions",
              subtitle: "Active & past prescriptions",
              icon: Icons.medication,
              color: Colors.purple,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            // Doctor Details
            _buildDashboardCard(
              context,
              title: "Assigned Doctor",
              subtitle: "Dr. Smith (Cardiologist)",
              icon: Icons.local_hospital,
              color: Colors.red,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            // Reminders
            _buildDashboardCard(
              context,
              title: "Reminders",
              subtitle: "2 pending medications today",
              icon: Icons.alarm,
              color: Colors.teal,
              onTap: () {},
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reports"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
