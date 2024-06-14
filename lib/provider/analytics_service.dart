import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';


/// `AnalyticsService` is a service class that provides various methods for logging events and setting user properties in Firebase Analytics.
///
/// It uses an instance of `FirebaseAnalytics` to log different types of events such as login, sign up, custom events, and sign out. It also provides methods to set the user ID and user properties for analytics tracking.
///
/// Methods:
/// - `getAnalyticsObserver()`: Returns a `FirebaseAnalyticsObserver` which can be used to observe analytics events.
/// - `logLogin(String method)`: Logs a login event with the specified method.
/// - `logSignUp()`: Logs a sign up event with 'email' as the sign up method.
/// - `logCustomEvent({required String eventName, Map<String, dynamic>? parameters})`: Logs a custom event with the specified event name and parameters.
/// - `setUserId(String userId)`: Sets the user ID for analytics tracking.
/// - `setUserProperty({required String name, required String value})`: Sets a user property for analytics tracking.
/// - `logSignOut()`: Logs a sign out event.

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Returns a [FirebaseAnalyticsObserver] which can be used to observe analytics events.
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  /// Logs a login event with the specified [method].
  ///
  /// [method] is the method used for login.
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Logs a sign up event with 'email' as the sign up method.
  Future<void> logSignUp() async {
    await _analytics.logSignUp(signUpMethod: 'email');
  }

  /// Logs a custom event with the specified [eventName] and [parameters].
  ///
  /// [eventName] is the name of the event.
  /// [parameters] is a map of parameters related to the event.
  Future<void> logCustomEvent({required String eventName, Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(name: eventName, parameters: parameters);
  }

  /// Sets the user ID for analytics tracking.
  ///
  /// [userId] is the ID of the user.
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Sets a user property for analytics tracking.
  ///
  /// [name] is the name of the property.
  /// [value] is the value of the property.
  Future<void> setUserProperty({required String name, required String value}) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// Logs a sign out event.
  Future<void> logSignOut() async{
    await _analytics.logEvent(name: 'sign_out');
  }
}
