import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:medinotesapp/config/Shared_Preference_Data_Handling.dart';
import 'package:medinotesapp/screens/auth/login_screen.dart';
import 'package:medinotesapp/screens/doctor/patient_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  SharedPreferenceData sharedPref = SharedPreferenceData();
  await sharedPref.initialize();
  String? token = await sharedPref.getToken();

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,

      ),
      home: token != null  && token != "token"
          ? const PatientListScreen()
          : const LoginScreen(),
    );
  }
}
