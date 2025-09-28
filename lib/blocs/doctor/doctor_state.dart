abstract class DoctorState {}
abstract class DoctorActionState extends DoctorState{}
class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {}
class DoctorLoaded extends DoctorState {
  final List<String> doctors;
  DoctorLoaded(this.doctors);
}
class DoctorError extends DoctorState {
  final String message;
  DoctorError(this.message);
}


class DoctorLoginWaitingState extends DoctorActionState{}
class DoctorLoginSuccessState extends DoctorActionState{}
class DoctorLoginErrorState extends DoctorActionState{}


class DoctorGetPatientsWaitingState extends DoctorActionState{}
class DoctorGetPatientsSuccessState extends DoctorActionState{
  List<dynamic> data;
  DoctorGetPatientsSuccessState(this.data);
}
class DoctorGetPatientsErrorState extends DoctorActionState{}