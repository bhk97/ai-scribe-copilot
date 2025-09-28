import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medinotesapp/blocs/sign_up/sign_up_bloc.dart';
import 'package:medinotesapp/screens/doctor/patient_list_screen.dart';
import 'package:medinotesapp/screens/patient/patient_dashboard.dart';

class SignUpScreen extends StatefulWidget {
  final String userType;
  const SignUpScreen({super.key, required this.userType});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _doctorIdController = TextEditingController();
  bool _obscurePassword = true;

  final SignUpBloc signUpBloc = SignUpBloc();

  @override
  Widget build(BuildContext context) {
    bool isDoctor = widget.userType == "doctor";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Sign Up as ${isDoctor ? "Doctor" : "Patient"}"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: BlocConsumer<SignUpBloc, SignUpState>(
        bloc: signUpBloc,
        listener: (context, state) {
          if (state is SignUpSuccessState) {
            if (widget.userType == "doctor") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const PatientListScreen()),
                    (route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const PatientDashboardScreen()),
                    (route) => false,
              );
            }
          } else if (state is SignUpErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Sign Up Failed. Try again.")),
            );
          }
        },
        builder: (context, state) {
          if (state is SignUpWaitingState) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  Icon(Icons.person_add, size: 80, color: Colors.blue.shade700),
                  const SizedBox(height: 16),

                  // Name
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Patient-specific field
                  if (!isDoctor) ...[
                    TextField(
                      controller: _userIdController,
                      decoration: InputDecoration(
                        labelText: "User ID",
                        prefixIcon: const Icon(Icons.account_circle),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Doctor ID (required for both)
                  TextField(
                    controller: _doctorIdController,
                    decoration: InputDecoration(
                      labelText: "Doctor ID",
                      prefixIcon: const Icon(Icons.medical_services_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        if (isDoctor) {
                          signUpBloc.add(SignUpMainEvent({
                            "email": _emailController.text,
                            "password": _passwordController.text,
                            "name": _nameController.text,
                            "doctor_id": _doctorIdController.text,
                          }, "doctor"));
                        } else {
                          signUpBloc.add(SignUpMainEvent({
                            "email": _emailController.text,
                            "password": _passwordController.text,
                            "name": _nameController.text,
                            "user_id": _userIdController.text,
                            "doctor_id": _doctorIdController.text,
                          }, "patient"));
                        }
                      },
                      child: const Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
