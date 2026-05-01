import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../core/design_system/app_theme.dart';
import '../features/session/presentation/cubit/session_cubit.dart';
import 'router/app_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionCubit>.value(
      value: GetIt.I<SessionCubit>(),
      child: MaterialApp(
        title: 'ScaleBook', // L10N
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AppGate(),
      ),
    );
  }
}
