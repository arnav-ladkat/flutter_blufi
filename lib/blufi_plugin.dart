import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

typedef ResultCallback = void Function(String? data);

class BlufiPlugin {
  final MethodChannel? _channel = const MethodChannel('blufi_plugin');
  final EventChannel _eventChannel = EventChannel('blufi_plugin/state');

  BlufiPlugin._() {
    _channel!.setMethodCallHandler(null);

    _eventChannel
        .receiveBroadcastStream()
        .listen(speechResultsHandler, onError: speechResultErrorHandler);
  }

  ResultCallback? _resultSuccessCallback;
  ResultCallback? _resultErrorCallback;

  static BlufiPlugin _instance = new BlufiPlugin._();
  static BlufiPlugin get instance => _instance;

  void onMessageReceived(
      {ResultCallback? successCallback, ResultCallback? errorCallback}) {
    _resultSuccessCallback = successCallback;
    _resultErrorCallback = errorCallback;
  }

  Future<String?> get platformVersion async {
    final String? version = await _channel!.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<bool?> scanDeviceInfo({String? filterString}) async {
    final bool? isEnable = await _channel!.invokeMethod(
        'scanDeviceInfo', <String, dynamic>{'filter': filterString});
    return isEnable;
  }

  Future stopScan() async {
    return await _channel!.invokeMethod('stopScan');
  }

  Future connectPeripheral({String? peripheralAddress}) async {
    return await _channel!.invokeMethod('connectPeripheral',
        <String, dynamic>{'peripheral': peripheralAddress});
  }

  Future requestCloseConnection() async {
    return await _channel!.invokeMethod('requestCloseConnection');
  }

  Future negotiateSecurity() async {
    return await _channel!.invokeMethod('negotiateSecurity');
  }

  Future requestDeviceVersion() async {
    return await _channel!.invokeMethod('requestDeviceVersion');
  }

  Future configProvision({String? username, String? password}) async {
    return await _channel!.invokeMethod('configProvision',
        <String, dynamic>{'username': username, 'password': password});
  }

  Future requestDeviceStatus() async {
    return await _channel!.invokeMethod('requestDeviceStatus');
  }

  Future requestDeviceScan() async {
    return await _channel!.invokeMethod('requestDeviceScan');
  }

  Future postCustomData(Uint8List dataStr) async {
    return await _channel!.invokeMethod(
        'postCustomData', <String, dynamic>{'custom_data': dataStr});
  }

  Future<bool> isConnected() async {
    final bool? isConnected = await _channel!.invokeMethod('isConnected');
    return isConnected ?? false;
  }

  speechResultsHandler(dynamic event) {
    if (_resultSuccessCallback != null) _resultSuccessCallback!(event);
  }

  speechResultErrorHandler(dynamic error) {
    if (_resultErrorCallback != null) _resultErrorCallback!(error);
  }
}
