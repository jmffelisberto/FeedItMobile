import 'dart:async';
import 'package:multilogin2/utils/issue.dart';

class ConnectivityService {
  static const _checkInterval = Duration(seconds: 30);
  late Timer _connectivityTimer;
  final void Function()? fetchCloudIssues;

  ConnectivityService({this.fetchCloudIssues}) {
    _connectivityTimer = Timer.periodic(_checkInterval, (timer) {
      _checkInternetConnectivity();
    });
  }

  void _checkInternetConnectivity() async {
    if (await Issue.hasInternetConnection()) {
      await Issue.submitLocalIssues();
      fetchCloudIssues?.call(); // Call the callback function if it's not null
    }
  }

  void dispose() {
    _connectivityTimer.cancel();
  }
}
