import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ConnectivityStatus { online, offline, syncing }

class ConnectivityState {
  final ConnectivityStatus status;
  final bool isSyncing;

  const ConnectivityState({
    required this.status,
    this.isSyncing = false,
  });

  bool get isOnline => status == ConnectivityStatus.online || status == ConnectivityStatus.syncing;

  ConnectivityState copyWith({
    ConnectivityStatus? status,
    bool? isSyncing,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity;
  StreamSubscription? _subscription;

  ConnectivityCubit({Connectivity? connectivity}) 
    : _connectivity = connectivity ?? Connectivity(),
      super(const ConnectivityState(status: ConnectivityStatus.online)) {
    _init();
  }

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.none)) {
      emit(state.copyWith(status: ConnectivityStatus.offline));
    } else {
      emit(state.copyWith(status: ConnectivityStatus.online));
    }
  }

  void setSyncing(bool syncing) {
    emit(state.copyWith(
      status: syncing ? ConnectivityStatus.syncing : (state.isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline),
      isSyncing: syncing,
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
