import 'package:dio/dio.dart';
import 'package:medinotesapp/apis/endpoint_file.dart';
import 'package:medinotesapp/config/TokenInterceptor.dart';

class SignUpRepo {
  final Dio _dio = Dio();

  SignUpRepo() {
    _dio.interceptors.add(TokenInterceptor());
  }

  Future<bool> signUpUserMethod(Map<String,String> user, String role) async {
    bool status = false;
    try{
      if(role == "doctor"){
        var resp = await _dio.post(doctorSignUpEndPoint, data: user);
        if(resp.statusCode==200 || resp.statusCode==201){
          status = true;
        }
      }
      else{
        var resp = await _dio.post(patientSignUpEndPoint, data: user);
        if(resp.statusCode==200 || resp.statusCode==201){
          status = true;
        }
      }
    }
    catch(e){
      print("Sign Up Failed $e");
    }
    return status;
  }
}