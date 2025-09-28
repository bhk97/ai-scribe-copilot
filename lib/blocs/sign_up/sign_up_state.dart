part of 'sign_up_bloc.dart';

@immutable
abstract class SignUpState {}
abstract class SignUpActionState extends SignUpState{}
class SignUpInitial extends SignUpState {}


class SignUpWaitingState extends SignUpState{}
class SignUpSuccessState extends SignUpState{}
class SignUpErrorState extends SignUpState{}