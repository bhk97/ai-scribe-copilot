import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medinotesapp/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medinotesapp/blocs/doctor/doctor_bloc.dart';
import 'package:medinotesapp/blocs/doctor/doctor_event.dart';
import 'package:medinotesapp/blocs/doctor/doctor_state.dart';
import 'package:medinotesapp/screens/doctor/patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final DoctorBloc doctorBloc = DoctorBloc();

  @override
  void initState() {
    super.initState();
    // Fetch patients when screen opens
    doctorBloc.add(DoctorGetPatientsEvent());
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token"); // Clear saved token
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patients"),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          )
        ],
      ),
      body: BlocBuilder<DoctorBloc, DoctorState>(
        bloc: doctorBloc,
        builder: (context, state) {
          if (state is DoctorGetPatientsWaitingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DoctorGetPatientsSuccessState) {
            final patients = state.data as List<Map<String, dynamic>>;

            if (patients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text("No patients found",
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                doctorBloc.add(DoctorGetPatientsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          patient["name"].toString()[0].toUpperCase(),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700),
                        ),
                      ),
                      title: Text(
                        patient["name"],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        "User ID: ${patient["user_id"]}\nDoctor ID: ${patient["doctor_id"]}",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientDetailScreen(patient: patient),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          } else if (state is DoctorGetPatientsErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  const Text("Failed to load patients", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      doctorBloc.add(DoctorGetPatientsEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  )
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
