import 'dart:async';
import 'dart:isolate';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vybe/blocs/engine/engine_bloc.dart';
import 'package:vybe/blocs/login/login_cubit.dart';
import 'package:vybe/screens/call.dart';
import 'package:vybe/screens/home.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/call/call_bloc.dart';
import 'config/agora.config.dart';
import 'firebase_options.dart';

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  // Do your work here...

  BackgroundFetch.finish(taskId);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  GetIt.I.registerSingleton<AgoraRtmClient>(
      await AgoraRtmClient.createInstance(appId));
  GetIt.I.registerSingleton<RtcEngine>(await RtcEngine.create(appId));
  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;
  runApp(App(
    authenticationRepository: authenticationRepository,
  ));
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class App extends StatelessWidget {
  const App({
    Key? key,
    required this.authenticationRepository,
  }) : super(key: key);

  final AuthenticationRepository authenticationRepository;
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authenticationRepository: authenticationRepository,
            ),
          ),
          BlocProvider(
            create: (context) =>
                LoginCubit(authenticationRepository, GetIt.I<AgoraRtmClient>()),
          ),
          BlocProvider(
            create: (context) =>
                CallBloc(GetIt.I<AgoraRtmClient>(), GetIt.I<RtcEngine>()),
          ),
          BlocProvider(
            create: (context) => EngineBloc(GetIt.I<RtcEngine>()),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<LoginCubit>().logInAnonymously();
    _handleRtcClientEvent(context);
    _handleRtcEngineEvent(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'vybe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocListener<CallBloc, CallState>(
        listener: (context, state) {
          switch (state.status) {
            case CallStatus.dialing:
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CallScreen(
                        peer: state.invitation!.calleeId,
                      )));
              break;
            case CallStatus.ringing:
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CallScreen(
                        peer: state.invite!.callerId,
                        incoming: true,
                      )));
              break;
            default:
          }
        },
        child: const HomeScreen(),
      ),
    );
  }

  Future<void> _handleRtcClientEvent(BuildContext context) async {
    final client = GetIt.I<AgoraRtmClient>();
// Caller Events
    client.onLocalInvitationReceivedByPeer =
        (AgoraRtmLocalInvitation invitation) {
      context.read<CallBloc>().add(CallDialing(invitation));
    };
    client.onLocalInvitationAccepted = (AgoraRtmLocalInvitation invitation) {
      context.read<CallBloc>().add(CallAccepted(invitation));
    };
    client.onLocalInvitationRefused = (AgoraRtmLocalInvitation invitation) {
      context.read<CallBloc>().add(CallDeclined(invitation));
    };
    client.onLocalInvitationFailure =
        (AgoraRtmLocalInvitation invitation, int errorCode) =>
            context.read<CallBloc>().add(const CallFailed());

    // Callee Events
    client.onRemoteInvitationReceivedByPeer =
        (AgoraRtmRemoteInvitation invite) =>
            context.read<CallBloc>().add(CallRinging(invite));
    client.onRemoteInvitationAccepted = (AgoraRtmRemoteInvitation invite) =>
        context.read<CallBloc>().add(CallRecieved(invite));
    client.onRemoteInvitationFailure =
        (AgoraRtmRemoteInvitation invite, int errorCode) =>
            context.read<CallBloc>().add(const CallFailed());
    client.onRemoteInvitationCanceled = (AgoraRtmRemoteInvitation invite) =>
        context.read<CallBloc>().add(CallMissed(invite));

    // General
    client.onConnectionStateChanged = (int state, int reason) {
      if (state == 5) {
        client.logout();
      }
    };
    client.onError = () => context.read<CallBloc>().add(const CallFailed());
  }

  void _handleRtcEngineEvent(BuildContext context) async {
    final engine = GetIt.I<RtcEngine>();
    await engine.enableAudio();
    await engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await engine.setClientRole(ClientRole.Broadcaster);
    engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        context.read<EngineBloc>().add(EngineError());
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        context.read<EngineBloc>().add(EngineJoinChannel());
      },
      leaveChannel: (stats) {
        context.read<EngineBloc>().add(EngineLeaveChannel(stats));
      },
      userJoined: (uid, elapsed) {
        print('User Joined');
      },
      userOffline: (uid, reason) {
        if (reason == UserOfflineReason.Quit) {
          context.read<EngineBloc>().add(EngineRemoteUserLeaveChannel());
        }
      },
      connectionLost: () {
        context.read<EngineBloc>().add(EngineConnectionLost());
      },
      rejoinChannelSuccess: (channel, uid, elapsed) {
        context.read<EngineBloc>().add(EngineJoinChannel());
      },
      rtcStats: (stats) {
        if (stats.userCount > 1) {
          context.read<EngineBloc>().add(EngineCallConnected(stats));
        }
      },
    ));
  }
}
