part of 'engine_bloc.dart';

enum ComEngineStatus {
  disconnected,
  connecting,
  failed,
  connected,
  reconnecting,
}

class EngineState extends Equatable {
  const EngineState._({required this.status, this.stats});

  const EngineState.disconnected()
      : this._(status: ComEngineStatus.disconnected);

  const EngineState.connecting() : this._(status: ComEngineStatus.connecting);

  const EngineState.failed() : this._(status: ComEngineStatus.failed);

  const EngineState.connected(RtcStats stats)
      : this._(status: ComEngineStatus.connected, stats: stats);

  const EngineState.reconnecting()
      : this._(status: ComEngineStatus.reconnecting);

  final ComEngineStatus status;
  final RtcStats? stats;

  @override
  List<Object> get props => [status];
}
