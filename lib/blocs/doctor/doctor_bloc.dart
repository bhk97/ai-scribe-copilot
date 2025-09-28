import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medinotesapp/repositories/doctor_repository.dart';
import 'doctor_event.dart';
import 'doctor_state.dart';

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  DoctorBloc() : super(DoctorInitial()) {
    on<DoctorLoginEvent>(doctorLoginEvent);
    on<DoctorGetPatientsEvent>(doctorGetPatientsEvent);
  }

  FutureOr<void> doctorLoginEvent(DoctorLoginEvent event, Emitter<DoctorState> emit) async {
    emit(DoctorLoginWaitingState());
    var data = await DoctorRepo().loginDoctor(email: event.email, password: event.password, context: event.context,role: event.role);
    if(data){
      emit(DoctorLoginSuccessState());
    }
    else{
      emit(DoctorLoginErrorState());
    }
  }

  FutureOr<void> doctorGetPatientsEvent(DoctorGetPatientsEvent event, Emitter<DoctorState> emit) async {
    emit(DoctorGetPatientsWaitingState());
    try{
      List<dynamic> data = await DoctorRepo().getPatientsByDoctorId();
      emit(DoctorGetPatientsSuccessState(data));
    }
        catch(e){
      emit(DoctorGetPatientsErrorState());
        }
  }
}
