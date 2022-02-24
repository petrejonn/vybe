import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/src/provider.dart';
import 'package:vybe/blocs/call/call_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff05102e),
      body: Column(
        children: [
          Expanded(
              flex: 2,
              child: Image(
                image: const NetworkImage(
                    'https://www.sec.gov/Archives/edgar/data/1802883/000162828020009726/agoralogo1d.jpg'),
                height: MediaQuery.of(context).size.height * 0.17,
              )),
          Expanded(
              child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Find your ',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32),
                  ),
                  Text(
                    'twin',
                    style: TextStyle(
                        color: Color(0xffe2508c),
                        fontWeight: FontWeight.bold,
                        fontSize: 32),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'soul ',
                    style: TextStyle(
                        color: Color(0xffe2508c),
                        fontWeight: FontWeight.bold,
                        fontSize: 32),
                  ),
                  Text(
                    'near you',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              CupertinoButton(
                child: const Text('Find Someone'),
                onPressed: () async {
                  await _handleMicPermission(Permission.microphone);
                  context.read<CallBloc>().add(CallInitiate());
                },
                color: const Color(0xffe2508c),
                borderRadius: const BorderRadius.all(Radius.circular(33.0)),
              )
            ],
          ))
        ],
      ),
    );
  }

  Future<void> _handleMicPermission(Permission permission) async {
    final status = await permission.request();
  }
}
