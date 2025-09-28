import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/doctor/doctor_bloc.dart';
import '../../blocs/doctor/doctor_event.dart';
import '../../blocs/doctor/doctor_state.dart';

class DoctorScreen extends StatelessWidget {
  const DoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorBloc()..add(LoadDoctors()),
      child: Scaffold(
        appBar: AppBar(title: const Text("Doctors")),
        body: BlocBuilder<DoctorBloc, DoctorState>(
          builder: (context, state) {
            if (state is DoctorLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DoctorLoaded) {
              return ListView.builder(
                itemCount: state.doctors.length,
                itemBuilder: (context, index) =>
                    ListTile(title: Text(state.doctors[index])),
              );
            } else if (state is DoctorError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text("Press button to load doctors"));
          },
        ),
      ),
    );
  }
}
