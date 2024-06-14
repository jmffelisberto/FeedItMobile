import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

import '../utils/issue.dart';

/// `InternetProvider` is a class that checks and provides the internet connectivity status.
///
/// It uses the `Connectivity` class from the `connectivity_plus` package to check the internet connectivity.
/// The connectivity status can be accessed using the `hasInternet` getter.
///
/// Methods:
/// - `InternetProvider()`: Constructor that calls `checkInternetConnection()` to set the initial connectivity status.
/// - `checkInternetConnection()`: Checks the internet connectivity and updates `_hasInternet`.
class InternetProvider extends ChangeNotifier{
  bool _hasInternet = false;

  /// Returns the current internet connectivity status.
  bool get hasInternet => _hasInternet;

  /// Constructor that calls `checkInternetConnection()` to set the initial connectivity status.
  InternetProvider(){
    checkInternetConnection();
  }

  /// Checks the internet connectivity and updates `_hasInternet`.
  ///
  /// It uses the `Connectivity` class from the `connectivity_plus` package to check the internet connectivity.
  /// If the result is `ConnectivityResult.none`, `_hasInternet` is set to `false`.
  /// Otherwise, `_hasInternet` is set to `true`.
  /// After updating `_hasInternet`, it calls `notifyListeners()` to notify all its listeners about the change.
  Future checkInternetConnection() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none){
      _hasInternet = false;
    }
    else {
      _hasInternet = true;
    }
    notifyListeners();
  }
}