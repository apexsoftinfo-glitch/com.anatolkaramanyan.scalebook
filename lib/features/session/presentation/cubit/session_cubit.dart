import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/user_session.dart';
import '../../domain/repositories/session_repository.dart';

/// SessionCubit exposes UserSession stream to UI.
/// This is a thin wrapper - all logic is in SessionRepository.
class SessionCubit extends Cubit<UserSession> {
  final SessionRepository _sessionRepository;
  StreamSubscription<UserSession>? _subscription;

  SessionCubit(this._sessionRepository)
      : super(const UserSession.initializing()) {
    _subscription = _sessionRepository.sessionStream.listen(
      emit,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[SessionCubit] Stream error: $error');
      },
    );
  }

  Future<void> refresh() => _sessionRepository.refresh();

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
