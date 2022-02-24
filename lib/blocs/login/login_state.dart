part of 'login_cubit.dart';

enum LoginStatus { init, successful, error, inprogress }

class LoginState extends Equatable {
  const LoginState({
    this.message,
    this.status = LoginStatus.init,
  });

  final String? message;
  final LoginStatus status;

  @override
  List<Object?> get props => [
        status,
      ];

  LoginState copyWith({
    String? message,
    LoginStatus? status,
  }) {
    return LoginState(
      message: message ?? this.message,
      status: status ?? this.status,
    );
  }
}
