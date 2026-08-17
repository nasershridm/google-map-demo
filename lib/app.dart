import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dndn/core/constants/app_constants.dart';
import 'package:dndn/core/di/injection.dart';
import 'package:dndn/core/services/connectivity_cubit.dart';
import 'package:dndn/core/theme/theme_cubit.dart';
import 'package:dndn/features/dashboard/presentation/pages/main_navigation_page.dart';
import 'package:dndn/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:dndn/features/reports/presentation/bloc/reports_event.dart';
import 'package:dndn/features/splash/presentation/pages/splash_page.dart';
import 'package:dndn/features/tracking/presentation/bloc/tracking_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
        BlocProvider<ConnectivityCubit>(create: (_) => getIt<ConnectivityCubit>()),
        BlocProvider<TrackingBloc>(create: (_) => getIt<TrackingBloc>()),
        BlocProvider<ReportsBloc>(
          create: (_) => getIt<ReportsBloc>()..add(const LoadTripsEvent()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E88E5),
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E88E5),
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
            ),
            initialRoute: '/',
            routes: {
              '/': (_) => const SplashPage(),
              '/home': (_) => const MainNavigationPage(),
            },
          );
        },
      ),
    );
  }
}
