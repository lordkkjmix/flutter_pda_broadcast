// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_pda_broadcast/flutter_pda_broadcast.dart';
// import 'package:flutter_pda_broadcast/flutter_pda_broadcast_platform_interface.dart';
// import 'package:flutter_pda_broadcast/flutter_pda_broadcast_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockFlutterPdaBroadcastPlatform
//     with MockPlatformInterfaceMixin
//     implements FlutterPdaBroadcastPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final FlutterPdaBroadcastPlatform initialPlatform = FlutterPdaBroadcastPlatform.instance;

//   test('$MethodChannelFlutterPdaBroadcast is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelFlutterPdaBroadcast>());
//   });

//   test('getPlatformVersion', () async {
//     FlutterPdaBroadcast flutterPdaBroadcastPlugin = FlutterPdaBroadcast();
//     MockFlutterPdaBroadcastPlatform fakePlatform = MockFlutterPdaBroadcastPlatform();
//     FlutterPdaBroadcastPlatform.instance = fakePlatform;

//     expect(await flutterPdaBroadcastPlugin.getPlatformVersion(), '42');
//   });
// }
