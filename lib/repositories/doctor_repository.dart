import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:medinotesapp/apis/endpoint_file.dart';
import 'package:medinotesapp/config/Shared_Preference_Data_Handling.dart';
import 'package:medinotesapp/config/TokenInterceptor.dart';
import 'package:medinotesapp/screens/doctor/patient_list_screen.dart';
import 'package:medinotesapp/screens/patient/patient_dashboard.dart';


class DoctorRepo {
  final Dio _dio = Dio();

  DoctorRepo() {
    _dio.interceptors.add(TokenInterceptor());
  }

  /// Doctor Login
  /// for runing on web we have to remove the buildcontext as an parameter
  Future<bool> loginDoctor({
    required String email,
    required String password,
    required BuildContext context,
    required String role
  }) async {
    try {
      if(role == "doctor"){
        final response = await _dio.post(
          doctorLogin, // replace later
          data: {
            "email": email,
            "password": password,
          },
        );

        final data = response.data;
        final token = data["token"];
        SharedPreferenceData sharedPreferenceData = SharedPreferenceData();
        sharedPreferenceData.initialize();
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        await sharedPreferenceData.storeToken(token);
        //handle later

        print(decodedToken);
        String userId = decodedToken["userid"];
        print(userId);
        await sharedPreferenceData.setUserID(userId);
        Navigator.pushReplacement(context , MaterialPageRoute(builder: (_) => PatientListScreen()));
      }else{
        final response = await _dio.post(
          patientLoginEndPoint, // replace later
          data: {
            "email": email,
            "password": password,
          },
        );

        final data = response.data;
        final token = data["token"];
        SharedPreferenceData sharedPreferenceData = SharedPreferenceData();
        sharedPreferenceData.initialize();
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        await sharedPreferenceData.storeToken(token);
        //handle later

        print(decodedToken);
        String userId = decodedToken["userid"];
        print(userId);
        await sharedPreferenceData.setUserID(userId);
        Navigator.pushReplacement(context , MaterialPageRoute(builder: (_) => PatientDashboardScreen()));
      }


      return true;
    } catch (e) {
      print("❌ Error in loginDoctor: $e");
      return false;
    }
  }



  /// Get Patients by Doctor Id
  Future<List<Map<String, dynamic>>> getPatientsByDoctorId() async {
    SharedPreferenceData sharedPreferenceData = SharedPreferenceData();
    await sharedPreferenceData.initialize();
    String doctorId = await sharedPreferenceData.getUserID();

    try {
      final response = await _dio.get(
        "$getPatientByDoctor/$doctorId",
      );

      print(response.data);

      // Cast each element to Map<String, dynamic>
      final data = (response.data["success"] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      return data;
    } catch (e) {
      print("❌ Error in getPatientsByDoctorId: $e");
      rethrow;
    }
  }


}
