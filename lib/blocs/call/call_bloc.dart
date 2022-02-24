import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:vybe/config/agora.config.dart';

part 'call_event.dart';
part 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  CallBloc(AgoraRtmClient agoraRtmClient, RtcEngine rtcEngine)
      : _agoraRtmClient = agoraRtmClient,
        _rtcEngine = rtcEngine,
        super(const CallState.waiting()) {
    on<CallDialing>(_onCallDialing);
    on<CallRinging>(_onCallRinging);
    on<CallInitiate>(_onCallInitiate);
    on<CallFailed>(_onCallFailed);
    on<CancelCall>(_onCancelCall);
    on<CallAccepted>(_onCallAccepted);
    on<CallDeclined>(_onCallDeclined);
    on<CallRecieved>(_onCallRecieved);
    on<CallMissed>(_onCallMissed);
    on<ReceiveCall>(_onReceiveCall);
    on<RefuseCall>(_onRefuseCall);
  }

  final AgoraRtmClient _agoraRtmClient;
  final RtcEngine _rtcEngine;

  void _onCallInitiate(CallInitiate event, Emitter<CallState> emit) async {
    try {
      AgoraRtmLocalInvitation invitation =
          // AgoraRtmLocalInvitation('accurateSituation', channelId: 'test');
          AgoraRtmLocalInvitation('unkemptAdvertising', channelId: 'test');
      await _agoraRtmClient.sendLocalInvitation(invitation.toJson());
    } catch (errorCode) {}
  }

  void _onCallFailed(CallFailed event, Emitter<CallState> emit) {
    emit(const CallState.failed());
  }

  void _onCallDialing(CallDialing event, Emitter<CallState> emit) {
    emit(CallState.dialing(event.invitation));
  }

  void _onCallAccepted(CallAccepted event, Emitter<CallState> emit) async {
    await _rtcEngine.joinChannel(token, event.invitation.channelId!, null, 0);
    emit(CallState.accepted(invitation: event.invitation));
  }

  void _onCallDeclined(CallDeclined event, Emitter<CallState> emit) {
    emit(CallState.declined(invitation: event.invitation));
  }

  void _onCallRecieved(CallRecieved event, Emitter<CallState> emit) async {
    // TODO: Join channel
    await _rtcEngine.joinChannel(token, event.invite.channelId!, null, 0);
    emit(CallState.accepted(invite: event.invite));
  }

  void _onCallRinging(CallRinging event, Emitter<CallState> emit) {
    emit(CallState.ringing(event.invite));
  }

  void _onCancelCall(CancelCall event, Emitter<CallState> emit) {
    _agoraRtmClient.cancelLocalInvitation(event.invitation.toJson());
    emit(const CallState.ended());
  }

  void _onCallMissed(CallMissed event, Emitter<CallState> emit) {
    emit(CallState.missed(event.invite));
  }

  void _onReceiveCall(ReceiveCall event, Emitter<CallState> emit) {
    _agoraRtmClient.acceptRemoteInvitation(event.invite.toJson());
  }

  void _onRefuseCall(RefuseCall event, Emitter<CallState> emit) {
    _agoraRtmClient.refuseRemoteInvitation(event.invite.toJson());
    emit(const CallState.ended());
  }
}
