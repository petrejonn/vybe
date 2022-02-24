import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'engine_event.dart';
part 'engine_state.dart';

class EngineBloc extends Bloc<EngineEvent, EngineState> {
  EngineBloc(RtcEngine rtcEngine)
      : _rtcEngine = rtcEngine,
        super(const EngineState.disconnected()) {
    on<EngineError>(_onEngineError);
    on<EngineJoinChannel>(_onEngineJoinChannel);
    on<EngineLeaveChannel>(_onEngineLeaveChannel);
    on<EngineConnectionLost>(_onEngineConnectionLost);
    on<EngineEndCall>(_onEngineEndCall);
    on<EngineCallConnected>(_onEngineCallConnected);
    on<EngineRemoteUserLeaveChannel>(_onEngineRemoteUserLeaveChannel);
    // on<EngineMuteCall>(_onEngineMuteCall);
  }
  final RtcEngine _rtcEngine;

  void _onEngineError(EngineError event, Emitter<EngineState> emit) {
    emit(const EngineState.failed());
  }

  void _onEngineJoinChannel(
      EngineJoinChannel event, Emitter<EngineState> emit) {
    emit(const EngineState.connecting());
  }

  void _onEngineLeaveChannel(
      EngineLeaveChannel event, Emitter<EngineState> emit) {
    emit(const EngineState.disconnected());
  }

  void _onEngineConnectionLost(
      EngineConnectionLost event, Emitter<EngineState> emit) {
    emit(const EngineState.reconnecting());
  }

  void _onEngineEndCall(EngineEndCall event, Emitter<EngineState> emit) {
    _rtcEngine.leaveChannel();
  }

  void _onEngineCallConnected(
      EngineCallConnected event, Emitter<EngineState> emit) {
    emit(EngineState.connected(event.stats));
  }

  void _onEngineRemoteUserLeaveChannel(
      EngineRemoteUserLeaveChannel event, Emitter<EngineState> emit) {
    _rtcEngine.leaveChannel();
  }

  // void _onEngineMuteCall(EngineMuteCall event, Emitter<EngineState> emit) {
  //   _rtcEngine.muteLocalAudioStream(event.muted);
  // }
}
