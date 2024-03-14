import 'dart:async';
import 'package:multilogin2/utils/issue.dart';

class ConnectivityService {
  static const _checkInterval = Duration(seconds: 30); // Adjust as needed
  late Timer _connectivityTimer;

  ConnectivityService() {
    _connectivityTimer = Timer.periodic(_checkInterval, (timer) {
      _checkInternetConnectivity();
    });
  }

  void _checkInternetConnectivity() async {
    // Check internet connectivity and submit local issues if available
    if (await Issue.hasInternetConnection()) {
      await Issue.submitLocalIssues();
    }
  }

  void dispose() {
    _connectivityTimer.cancel();
  }
}