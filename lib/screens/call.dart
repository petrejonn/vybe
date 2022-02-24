import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vybe/blocs/call/call_bloc.dart';
import 'package:vybe/blocs/engine/engine_bloc.dart';
import 'package:vybe/config/agora.config.dart';

class CallScreen extends StatefulWidget {
  CallScreen({Key? key, required this.peer, this.incoming = false})
      : super(key: key);
  String peer;
  bool incoming;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _accepted = false;
  String? _communicationState;
  Timer? _timeElasped;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff05102e),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CallBloc, CallState>(
            listener: (context, state) {
              switch (state.status) {
                case CallStatus.failed:
                  Navigator.of(context).pop();
                  break;
                case CallStatus.missed:
                  Navigator.of(context).pop();
                  break;
                case CallStatus.ended:
                  Navigator.of(context).pop();
                  break;
                case CallStatus.declined:
                  Navigator.of(context).pop();
                  break;
                case CallStatus.accepted:
                  setState(() {
                    _accepted = true;
                  });
                  break;
                default:
              }
            },
          ),
          BlocListener<EngineBloc, EngineState>(
            listener: (context, state) {
              switch (state.status) {
                case ComEngineStatus.disconnected:
                  setState(() {
                    _communicationState = 'Disconnected';
                  });
                  Navigator.of(context).pop();
                  break;

                case ComEngineStatus.failed:
                  _timeElasped!.cancel();
                  setState(() {
                    _communicationState = 'Failed';
                  });
                  Navigator.of(context).pop();
                  break;

                case ComEngineStatus.reconnecting:
                  _timeElasped!.cancel();
                  setState(() {
                    _communicationState = 'Reconnecting';
                  });
                  break;

                case ComEngineStatus.connecting:
                  setState(() {
                    _communicationState = 'Connecting';
                  });
                  break;

                case ComEngineStatus.connected:
                  _timeElasped = Timer.periodic(Duration(seconds: 1), (timer) {
                    setState(() {
                      _communicationState = Duration(
                              seconds: (state.stats!.duration + timer.tick))
                          .toString()
                          .split('.')
                          .first
                          .padLeft(8, "0");
                      ;
                    });
                  });

                  break;

                default:
              }
            },
          ),
        ],
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      _communicationState != null
                          ? Text(
                              _communicationState!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          : Text(
                              widget.incoming ? 'Incoming...' : 'Calling...',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                      const SizedBox(
                        height: 48,
                      ),
                      Text(
                        widget.peer,
                        style: const TextStyle(
                            color: Color(0xffe2508c),
                            fontWeight: FontWeight.bold,
                            fontSize: 32),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _callActions(
                              icon: Icons.voicemail_rounded, text: 'Record'),
                          _callActions(
                              icon: Icons.pause_rounded,
                              text: 'Hold call',
                              enabled: false),
                          _callActions(
                              icon: Icons.bluetooth_rounded, text: 'Bluetooth'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _callActions(
                              icon: Icons.volume_up_rounded, text: 'Speaker'),
                          _callActions(
                              icon: Icons.mic_off_rounded,
                              text: 'Mute',
                              enabled: false),
                          _callActions(
                              icon: Icons.dialpad_rounded, text: 'Keypad'),
                        ],
                      ),
                      _accepted
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                              child: IconButton(
                                iconSize: 48,
                                onPressed: () {
                                  context
                                      .read<EngineBloc>()
                                      .add(EngineEndCall());
                                },
                                icon: const Icon(
                                  Icons.call_end_rounded,
                                ),
                                color: Colors.white,
                              ),
                            )
                          : widget.incoming
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle),
                                      child: IconButton(
                                        iconSize: 48,
                                        onPressed: () {
                                          context.read<CallBloc>().add(
                                              ReceiveCall(context
                                                  .read<CallBloc>()
                                                  .state
                                                  .invite!));
                                        },
                                        icon: const Icon(
                                          Icons.call_end_rounded,
                                        ),
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle),
                                      child: IconButton(
                                        iconSize: 48,
                                        onPressed: () {
                                          context.read<CallBloc>().add(
                                              RefuseCall(context
                                                  .read<CallBloc>()
                                                  .state
                                                  .invite!));
                                        },
                                        icon: const Icon(
                                          Icons.call_end_rounded,
                                        ),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle),
                                  child: IconButton(
                                    iconSize: 48,
                                    onPressed: () {
                                      context.read<CallBloc>().add(CancelCall(
                                          context
                                              .read<CallBloc>()
                                              .state
                                              .invitation!));
                                    },
                                    icon: const Icon(
                                      Icons.call_end_rounded,
                                    ),
                                    color: Colors.white,
                                  ),
                                )
                    ],
                  ),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _callActions(
      {required IconData icon,
      required String text,
      VoidCallback? callback,
      bool enabled = true}) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: enabled ? Colors.white : Colors.grey,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          text,
          style: TextStyle(
              color: enabled ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
