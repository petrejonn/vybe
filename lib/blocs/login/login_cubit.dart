import 'package:agora_rtm/agora_rtm.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository, AgoraRtmClient agoraRtmClient)
      : _agoraRtmClient = agoraRtmClient,
        super(const LoginState());

  final AuthenticationRepository _authenticationRepository;
  final AgoraRtmClient _agoraRtmClient;

  Future<void> logInAnonymously() async {
    emit(state.copyWith(status: LoginStatus.inprogress));
    try {
      await _authenticationRepository.logInAnonymously();
      emit(state.copyWith(
          message: 'Login Successful', status: LoginStatus.successful));
      if (_authenticationRepository.currentUser.isNotEmpty) {
        try {
          await _agoraRtmClient.login(
              null, _authenticationRepository.currentUser.displayName!);
        } catch (errorCode) {}
      }
    } on LogInAnonymouslyFailure catch (e) {
      emit(state.copyWith(message: e.message, status: LoginStatus.error));
    } catch (_) {
      emit(state.copyWith(
          message: 'An Unexpected Error Occured', status: LoginStatus.error));
    }
  }
}
