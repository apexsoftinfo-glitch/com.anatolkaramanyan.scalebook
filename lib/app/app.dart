import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:scalebook/l10n/app_localizations.dart';
import '../core/design_system/app_theme.dart';
import '../features/home/presentation/cubit/home_cubit.dart';
import '../features/notes/presentation/cubit/notes_cubit.dart';
import '../features/session/presentation/cubit/session_cubit.dart';
import '../features/session/presentation/cubit/locale_cubit.dart';
import 'router/app_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>.value(value: GetIt.I<SessionCubit>()),
        BlocProvider<HomeCubit>.value(value: GetIt.I<HomeCubit>()..loadProjects()),
        BlocProvider<NotesCubit>.value(value: GetIt.I<NotesCubit>()..loadNotes()),
        BlocProvider<LocaleCubit>.value(value: GetIt.I<LocaleCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            onGenerateTitle: (context) => S.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.supportedLocales,
            locale: locale,
            home: const AppGate(),
          );
        },
      ),
    );
  }
}
