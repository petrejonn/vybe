part of 'call_bloc.dart';

enum CallStatus {
  waiting,
  dialing,
  failed,
  ringing,
  declined,
  accepted,
  missed,
  ended,
}

@immutable
class CallState extends Equatable {
  const CallState._({required this.status, this.invite, this.invitation});

  const CallState.waiting() : this._(status: CallStatus.waiting);

  const CallState.dialing(AgoraRtmLocalInvitation invitation)
      : this._(status: CallStatus.dialing, invitation: invitation);
  const CallState.failed() : this._(status: CallStatus.failed);
  const CallState.ringing(AgoraRtmRemoteInvitation? invite)
      : this._(status: CallStatus.ringing, invite: invite);
  const CallState.declined(
      {AgoraRtmLocalInvitation? invitation, AgoraRtmRemoteInvitation? invite})
      : this._(
            status: CallStatus.declined,
            invitation: invitation,
            invite: invite);

  const CallState.accepted(
      {AgoraRtmLocalInvitation? invitation, AgoraRtmRemoteInvitation? invite})
      : this._(
            status: CallStatus.accepted,
            invitation: invitation,
            invite: invite);
  const CallState.ended()
      : this._(
          status: CallStatus.ended,
        );
  const CallState.missed(AgoraRtmRemoteInvitation? invite)
      : this._(status: CallStatus.missed, invite: invite);

  final CallStatus status;
  final AgoraRtmLocalInvitation? invitation;
  final AgoraRtmRemoteInvitation? invite;

  @override
  List<Object> get props => [
        status,
      ];
}
