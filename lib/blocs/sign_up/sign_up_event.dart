part of 'sign_up_bloc.dart';

@immutable
abstract class SignUpEvent {}
class SignUpMainEvent extends SignUpEvent{
  Map<String,String> user;
  String role;
  SignUpMainEvent(this.user, this.role);
}
