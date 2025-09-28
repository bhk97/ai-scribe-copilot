import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medinotesapp/blocs/doctor/doctor_bloc.dart';
import 'package:medinotesapp/blocs/doctor/doctor_event.dart';
import 'package:medinotesapp/blocs/doctor/doctor_state.dart';
import 'package:medinotesapp/screens/auth/signup_screen.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  bool isDoctor = true; // toggle state
  final DoctorBloc doctorBloc = DoctorBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<DoctorBloc, DoctorState>(
        buildWhen: (previous, current) => current is! DoctorActionState,
        listenWhen: (previous, current) => current is DoctorActionState,
        bloc: doctorBloc,
        listener: (context, state) {
          switch(state.runtimeType){
            case DoctorLoginWaitingState:
              print("Login Waiting");
              break;
            case DoctorLoginErrorState:
              print("Login Error");
              break;
            case DoctorLoginSuccessState:
              print("Login Success");
              break;
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 80, color: Colors.blue.shade700),
                  const SizedBox(height: 16),
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Login as ${isDoctor ? 'Doctor' : 'Patient'}",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("Doctor"),
                        selected: isDoctor,
                        onSelected: (selected) {
                          setState(() {
                            isDoctor = true;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text("Patient"),
                        selected: !isDoctor,
                        onSelected: (selected) {
                          setState(() {
                            isDoctor = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

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
                  const SizedBox(height: 24),

                  // Login Button
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
                        if(isDoctor){
                          doctorBloc.add(DoctorLoginEvent(_emailController.text, _passwordController.text, context, "doctor"));
                        } else {

                          doctorBloc.add(DoctorLoginEvent(_emailController.text, _passwordController.text, context, "patient"));
                          // Handle patient login
                          print("Patient login pressed");
                        }
                      },
                      child: const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SignUpScreen(userType: isDoctor ? "doctor" : "patient"),
                            ),
                          );
                        },
                        child: Text("Create Account", style: TextStyle(color: Colors.blue.shade700)),
                      ),
                    ],
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

