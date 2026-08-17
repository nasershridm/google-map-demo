import 'package:equatable/equatable.dart';
import 'package:dndn/features/tracking/domain/entities/location_point.dart';

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

class CheckPermissionsEvent extends TrackingEvent {
  const CheckPermissionsEvent();
}

class StartTrackingRequestedEvent extends TrackingEvent {
  final String? customTripId;
  const StartTrackingRequestedEvent({this.customTripId});

  @override
  List<Object?> get props => [customTripId];
}

class StopTrackingRequestedEvent extends TrackingEvent {
  const StopTrackingRequestedEvent();
}

class PauseTrackingRequestedEvent extends TrackingEvent {
  const PauseTrackingRequestedEvent();
}

class ResumeTrackingRequestedEvent extends TrackingEvent {
  const ResumeTrackingRequestedEvent();
}

class LocationPointReceivedEvent extends TrackingEvent {
  final LocationPoint point;
  const LocationPointReceivedEvent(this.point);

  @override
  List<Object?> get props => [point];
}

class TrackingTimerTickedEvent extends TrackingEvent {
  final int elapsedSeconds;
  const TrackingTimerTickedEvent(this.elapsedSeconds);

  @override
  List<Object?> get props => [elapsedSeconds];
}
