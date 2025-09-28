import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:medinotesapp/repositories/sign_up_repository.dart';
import 'package:meta/meta.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(SignUpInitial()) {
    on<SignUpMainEvent>(signUpMainEvent);
  }

  FutureOr<void> signUpMainEvent(SignUpMainEvent event, Emitter<SignUpState> emit) async {
    emit(SignUpWaitingState());
    bool status = await SignUpRepo().signUpUserMethod(event.user, event.role);
    if(status){
      emit(SignUpSuccessState());
    }
    else{
      emit(SignUpErrorState());
    }
  }
}
