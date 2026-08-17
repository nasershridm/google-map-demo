import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityCubit extends Cubit<bool> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(true) {
    _init();
  }

  Future<void> _init() async {
    try {
      final results = await _connectivity.checkConnectivity();
      emit(_isOnline(results));
    } catch (_) {
      emit(true);
    }

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      emit(_isOnline(results));
    });
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
