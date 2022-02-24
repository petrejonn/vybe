part of 'call_bloc.dart';

@immutable
abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object> get props => [];
}

class CallInitiate extends CallEvent {}

class CallFailed extends CallEvent {
  const CallFailed({this.invitation, this.errorCode});

  final AgoraRtmLocalInvitation? invitation;
  final int? errorCode;

  @override
  List<Object> get props => [];
}

class CallDialing extends CallEvent {
  const CallDialing(this.invitation);

  final AgoraRtmLocalInvitation invitation;

  @override
  List<Object> get props => [invitation];
}

class CancelCall extends CallEvent {
  const CancelCall(this.invitation);

  final AgoraRtmLocalInvitation invitation;

  @override
  List<Object> get props => [invitation];
}

class CallRinging extends CallEvent {
  const CallRinging(this.invite);

  final AgoraRtmRemoteInvitation invite;

  @override
  List<Object> get props => [invite];
}

class CallAccepted extends CallEvent {
  const CallAccepted(this.invitation);

  final AgoraRtmLocalInvitation invitation;

  @override
  List<Object> get props => [invitation];
}

class CallDeclined extends CallEvent {
  const CallDeclined(this.invitation);

  final AgoraRtmLocalInvitation invitation;

  @override
  List<Object> get props => [invitation];
}

class CallRecieved extends CallEvent {
  const CallRecieved(this.invite);

  final AgoraRtmRemoteInvitation invite;

  @override
  List<Object> get props => [invite];
}

class CallMissed extends CallEvent {
  const CallMissed(this.invite);

  final AgoraRtmRemoteInvitation invite;

  @override
  List<Object> get props => [invite];
}

class ReceiveCall extends CallEvent {
  const ReceiveCall(this.invite);

  final AgoraRtmRemoteInvitation invite;

  @override
  List<Object> get props => [invite];
}

class RefuseCall extends CallEvent {
  const RefuseCall(this.invite);

  final AgoraRtmRemoteInvitation invite;

  @override
  List<Object> get props => [invite];
}


// callfailed*
// calldialing*
// cancelCall*
// callDeclined*
// callAccepted*
// acceptCall
// declineCall
// callCanceled
// ringing*