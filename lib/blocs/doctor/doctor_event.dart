import 'package:flutter/cupertino.dart';

abstract class DoctorEvent {}

class LoadDoctors extends DoctorEvent {}

class DoctorLoginEvent extends DoctorEvent{
  var email;
  var password;
  BuildContext context;
  String role;
  DoctorLoginEvent(this.email, this.password, this.context, this.role);
}

class DoctorGetPatientsEvent extends DoctorEvent{

}