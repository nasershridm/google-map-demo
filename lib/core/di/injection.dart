import 'package:get_it/get_it.dart';
import 'package:dndn/core/services/connectivity_cubit.dart';
import 'package:dndn/core/services/database_helper.dart';
import 'package:dndn/core/theme/theme_cubit.dart';
import 'package:dndn/features/reports/data/repositories/trip_repository_impl.dart';
import 'package:dndn/features/reports/domain/repositories/trip_repository.dart';
import 'package:dndn/features/reports/domain/use_cases/incident_use_cases.dart';
import 'package:dndn/features/reports/domain/use_cases/trip_use_cases.dart';
import 'package:dndn/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:dndn/features/tracking/data/datasources/foreground_service_handler.dart';
import 'package:dndn/features/tracking/data/datasources/location_service_datasource.dart';
import 'package:dndn/features/tracking/data/datasources/tracking_local_datasource.dart';
import 'package:dndn/features/tracking/data/repositories/tracking_repository_impl.dart';
import 'package:dndn/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:dndn/features/tracking/domain/use_cases/tracking_use_cases.dart';
import 'package:dndn/features/tracking/presentation/bloc/tracking_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<DatabaseHelper>()) {
    return;
  }

  // -------------------------------------------------------------
  // 1. Core Services & Database
  // -------------------------------------------------------------
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // Initialize Foreground Service notification channel
  ForegroundServiceManager.initForegroundTask();

  // -------------------------------------------------------------
  // 2. Data Sources
  // -------------------------------------------------------------
  getIt.registerLazySingleton<TrackingLocalDataSource>(
    () => TrackingLocalDataSourceImpl(databaseHelper: getIt<DatabaseHelper>()),
  );

  getIt.registerLazySingleton<LocationServiceDataSource>(
    () => LocationServiceDataSourceImpl(),
  );

  // -------------------------------------------------------------
  // 3. Repositories
  // -------------------------------------------------------------
  getIt.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(
      locationDataSource: getIt<LocationServiceDataSource>(),
      localDataSource: getIt<TrackingLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(localDataSource: getIt<TrackingLocalDataSource>()),
  );

  // -------------------------------------------------------------
  // 4. Use Cases - Tracking
  // -------------------------------------------------------------
  getIt.registerLazySingleton(
    () => StartTrackingUseCase(getIt<TrackingRepository>()),
  );
  getIt.registerLazySingleton(
    () => StopTrackingUseCase(getIt<TrackingRepository>()),
  );
  getIt.registerLazySingleton(
    () => PauseTrackingUseCase(getIt<TrackingRepository>()),
  );
  getIt.registerLazySingleton(
    () => ResumeTrackingUseCase(getIt<TrackingRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetLocationStreamUseCase(getIt<TrackingRepository>()),
  );
  getIt.registerLazySingleton(
    () => CheckLocationPermissionsUseCase(getIt<TrackingRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetCurrentLocationUseCase(getIt<TrackingRepository>()),
  );

  // -------------------------------------------------------------
  // 5. Use Cases - Reports & Trips
  // -------------------------------------------------------------
  getIt.registerLazySingleton(() => GetTripsUseCase(getIt<TripRepository>()));
  getIt.registerLazySingleton(
    () => GetTripByIdUseCase(getIt<TripRepository>()),
  );
  getIt.registerLazySingleton(() => SaveTripUseCase(getIt<TripRepository>()));
  getIt.registerLazySingleton(() => UpdateTripUseCase(getIt<TripRepository>()));
  getIt.registerLazySingleton(() => DeleteTripUseCase(getIt<TripRepository>()));
  getIt.registerLazySingleton(
    () => SaveLocationPointUseCase(getIt<TripRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetDashboardMetricsUseCase(getIt<TripRepository>()),
  );

  // -------------------------------------------------------------
  // 5b. Use Cases - Incident Reports
  // -------------------------------------------------------------
  getIt.registerLazySingleton(
    () => SubmitIncidentReportUseCase(getIt<TripRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetIncidentReportsUseCase(getIt<TripRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteIncidentReportUseCase(getIt<TripRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetIncidentsForTripUseCase(getIt<TripRepository>()),
  );

  // -------------------------------------------------------------
  // 6. Blocs (Factory)
  // -------------------------------------------------------------
  getIt.registerFactory(
    () => TrackingBloc(
      startTrackingUseCase: getIt<StartTrackingUseCase>(),
      stopTrackingUseCase: getIt<StopTrackingUseCase>(),
      pauseTrackingUseCase: getIt<PauseTrackingUseCase>(),
      resumeTrackingUseCase: getIt<ResumeTrackingUseCase>(),
      getLocationStreamUseCase: getIt<GetLocationStreamUseCase>(),
      checkPermissionsUseCase: getIt<CheckLocationPermissionsUseCase>(),
      getTripByIdUseCase: getIt<GetTripByIdUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => ReportsBloc(
      getTripsUseCase: getIt<GetTripsUseCase>(),
      getTripByIdUseCase: getIt<GetTripByIdUseCase>(),
      deleteTripUseCase: getIt<DeleteTripUseCase>(),
      getDashboardMetricsUseCase: getIt<GetDashboardMetricsUseCase>(),
      submitIncidentReportUseCase: getIt<SubmitIncidentReportUseCase>(),
      getIncidentReportsUseCase: getIt<GetIncidentReportsUseCase>(),
      deleteIncidentReportUseCase: getIt<DeleteIncidentReportUseCase>(),
    ),
  );

  // -------------------------------------------------------------
  // 7. Theme & Connectivity Cubits
  // -------------------------------------------------------------
  getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  getIt.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit());
}
