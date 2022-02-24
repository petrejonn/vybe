part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthUserChanged extends AuthEvent {
  @visibleForTesting
  const AuthUserChanged(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

class AuthLogoutRequested extends AuthEvent {}
