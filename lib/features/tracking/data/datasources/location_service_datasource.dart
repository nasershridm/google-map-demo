import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:dndn/core/constants/app_constants.dart';
import 'package:dndn/core/errors/exceptions.dart';
import 'package:dndn/features/tracking/data/models/location_point_model.dart';

abstract class LocationServiceDataSource {
  Future<bool> isLocationServiceEnabled();
  Future<bool> hasPermission();
  Future<bool> requestPermissions();
  Future<Position> getCurrentPosition();
  Stream<LocationPointModel> getPositionStream({required String tripId});
}

class LocationServiceDataSourceImpl implements LocationServiceDataSource {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<Position> getCurrentPosition() async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationException(
          'Location services are disabled on device.',
        );
      }

      final permissionGranted = await hasPermission();
      if (!permissionGranted) {
        final requested = await requestPermissions();
        if (!requested) {
          throw const PermissionException('Location permissions were denied.');
        }
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      if (e is LocationException || e is PermissionException) rethrow;
      throw LocationException('Failed to get current location: $e');
    }
  }

  @override
  Stream<LocationPointModel> getPositionStream({required String tripId}) {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: AppConstants.minDistanceFilterMetersInt,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .where((position) {
          // ignore: avoid_print
          print('[DNDN_GPS_RAW] lat=${position.latitude.toStringAsFixed(6)}'
              ' lng=${position.longitude.toStringAsFixed(6)}'
              ' accuracy=${position.accuracy.toStringAsFixed(1)}m'
              ' speed=${(position.speed * 3.6).toStringAsFixed(1)}km/h');

          final passes = position.accuracy <= AppConstants.maxAcceptedGpsAccuracyMeters;
          if (!passes) {
            // ignore: avoid_print
            print('[DNDN_GPS_RAW] ⚠️ FILTERED OUT — accuracy ${position.accuracy.toStringAsFixed(1)}m > ${AppConstants.maxAcceptedGpsAccuracyMeters}m limit');
          }
          return passes;
        })
        .map((position) {
          // ignore: avoid_print
          print('[DNDN_GPS_ACCEPTED] ✅ Point accepted — accuracy ${position.accuracy.toStringAsFixed(1)}m');
          return LocationPointModel.fromPosition(
            position: position,
            tripId: tripId,
          );
        });
  }
}
