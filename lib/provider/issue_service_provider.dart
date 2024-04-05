import 'dart:async';
import 'package:multilogin2/utils/issue.dart';
import 'package:connectivity/connectivity.dart';

class ConnectivityService {
  static const _checkInterval = Duration(seconds: 3);
  late Timer _connectivityTimer;
  final void Function()? onConnectionRestored;

  ConnectivityService({this.onConnectionRestored, void Function()? fetchCloudIssues}) {
    _connectivityTimer = Timer.periodic(_checkInterval, (timer) {
      _checkInternetConnectivity(fetchCloudIssues);
    });
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _checkInternetConnectivity(void Function()? fetchCloudIssues) async {
    if (await checkConnectivity()) {
      // Call fetchCloudIssues callback if it's not null
      fetchCloudIssues?.call();
      // Call onConnectionRestored callback if it's not null
      onConnectionRestored?.call();
    }
  }

  void dispose() {
    _connectivityTimer.cancel();
  }
}
