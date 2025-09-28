import 'package:dio/dio.dart';
import 'package:medinotesapp/config/Shared_Preference_Data_Handling.dart';


class TokenInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final SharedPreferenceData sharedPreferenceData = SharedPreferenceData();
    await sharedPreferenceData.initialize();
    final token = await sharedPreferenceData.getToken();
    if (token != null) {
      options.headers['Authorization'] = '$token';
    }
    return handler.next(options);
  }

}