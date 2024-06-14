import 'dart:async';
import 'package:multilogin2/utils/issue.dart';
import 'package:connectivity/connectivity.dart';

/// `ConnectivityService` is a class that checks for internet connectivity at regular intervals.
///
/// It uses the `Connectivity` class from the `connectivity_plus` package to check the internet connectivity.
/// It also provides a callback `onConnectionRestored` which is called when the internet connection is restored.
///
/// Methods:
/// - `ConnectivityService({this.onConnectionRestored, void Function()? fetchCloudIssues})`: Constructor that starts a timer to check the internet connectivity at regular intervals.
/// - `checkConnectivity()`: Checks the internet connectivity and returns a boolean indicating whether there is an internet connection or not.
/// - `_checkInternetConnectivity(void Function()? fetchCloudIssues)`: Checks the internet connectivity and if the internet connection is restored, it calls the `fetchCloudIssues` and `onConnectionRestored` callbacks.
/// - `dispose()`: Cancels the timer.
class ConnectivityService {
  static const _checkInterval = Duration(seconds: 3);
  late Timer _connectivityTimer;
  final void Function()? onConnectionRestored;

  /// Constructor that starts a timer to check the internet connectivity at regular intervals.
  ///
  /// [onConnectionRestored] is a callback that is called when the internet connection is restored.
  /// [fetchCloudIssues] is a callback that is called when the internet connection is restored.
  ConnectivityService({this.onConnectionRestored, void Function()? fetchCloudIssues}) {
    _connectivityTimer = Timer.periodic(_checkInterval, (timer) {
      _checkInternetConnectivity(fetchCloudIssues);
    });
  }

  /// Checks the internet connectivity and returns a boolean indicating whether there is an internet connection or not.
  ///
  /// It uses the `Connectivity` class from the `connectivity_plus` package to check the internet connectivity.
  /// If the result is `ConnectivityResult.none`, it returns `false`.
  /// Otherwise, it returns `true`.
  Future<bool> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Checks the internet connectivity and if the internet connection is restored, it calls the `fetchCloudIssues` and `onConnectionRestored` callbacks.
  ///
  /// [fetchCloudIssues] is a callback that is called when the internet connection is restored.
  /// It uses the `checkConnectivity()` method to check the internet connectivity.
  /// If the internet connection is restored, it calls the `fetchCloudIssues` and `onConnectionRestored` callbacks.
  void _checkInternetConnectivity(void Function()? fetchCloudIssues) async {
    if (await checkConnectivity()) {
      // Call fetchCloudIssues callback if it's not null
      fetchCloudIssues?.call();
      // Call onConnectionRestored callback if it's not null
      onConnectionRestored?.call();
    }
  }

  /// Cancels the timer.
  void dispose() {
    _connectivityTimer.cancel();
  }
}
