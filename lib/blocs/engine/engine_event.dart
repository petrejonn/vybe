part of 'engine_bloc.dart';

abstract class EngineEvent extends Equatable {
  const EngineEvent();

  @override
  List<Object> get props => [];
}

class EngineError extends EngineEvent {}

class EngineJoinChannel extends EngineEvent {}

class EngineRemoteUserLeaveChannel extends EngineEvent {}

class EngineLeaveChannel extends EngineEvent {
  const EngineLeaveChannel(
    this.stats,
  );

  final RtcStats stats;

  @override
  List<Object> get props => [stats];
}

class EngineConnectionLost extends EngineEvent {}

class EngineEndCall extends EngineEvent {}

class EngineCallConnected extends EngineEvent {
  const EngineCallConnected(
    this.stats,
  );

  final RtcStats stats;

  @override
  List<Object> get props => [stats];
}

// class EngineMuteCall extends EngineEvent {
//   const EngineMuteCall(
//     this.muted,
//   );

//   final bool muted;

//   @override
//   List<Object> get props => [muted];
// }

// class EngineSpeaker extends EngineEvent {
//   const EngineSpeaker(
//     this.speaker,
//   );

//   final bool speaker;

//   @override
//   List<Object> get props => [speaker];
// }
