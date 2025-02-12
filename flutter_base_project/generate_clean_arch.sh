#!/bin/bash

# Flutter Clean Architecture Project Generator
# Usage: ./generate_clean_arch.sh project_name

# Check if project name is provided
if [ -z "$1" ]; then
    echo "Please provide a project name"
    echo "Usage: ./generate_clean_arch.sh project_name"
    exit 1
fi

PROJECT_NAME=$1

# Create Flutter project
flutter create $PROJECT_NAME -t app
cd $PROJECT_NAME

mkdir -p assets/{images,translations}

# Create app directories
mkdir -p lib/app/{router,services,util}

# Create core directory structure
mkdir -p lib/core/{arch,di}

# Create shared directories
mkdir -p lib/data/{res,src}

# Create shared directories
mkdir -p lib/domain/{controllers,insterfaces, models}

# Create shared directories
mkdir -p lib/presentation/{style,home,login}
mkdir -p lib/presentation/style/theme

# Create standard Clean Architecture layers for each feature
create_feature() {
    FEATURE_NAME=$1
    mkdir -p lib/features/$FEATURE_NAME/{data,domain,presentation}
    # Data layer
    mkdir -p lib/features/$FEATURE_NAME/data/{datasources,models,repositories}
    mkdir -p lib/features/$FEATURE_NAME/data/datasources/${FEATURE_NAME}_remote_data_source.dart
    mkdir -p lib/features/$FEATURE_NAME/data/datasources/${FEATURE_NAME}_local_data_source.dart
    mkdir -p lib/features/$FEATURE_NAME/data/models/${FEATURE_NAME}_model.dart
    mkdir -p lib/features/$FEATURE_NAME/data/repositories/${FEATURE_NAME}_repository_impl.dart

    # Domain layer
    mkdir -p lib/features/$FEATURE_NAME/domain/{entities,repositories,usecases}
    mkdir -p lib/features/$FEATURE_NAME/domain/entities/${FEATURE_NAME}.dart
    mkdir -p lib/features/$FEATURE_NAME/domain/repositories/${FEATURE_NAME}_repository.dart
    mkdir -p lib/features/$FEATURE_NAME/domain/usecases/get_${FEATURE_NAME}.dart

    # Presentation layer
    mkdir -p lib/features/$FEATURE_NAME/presentation/{bloc,pages,widgets}
    mkdir -p lib/features/$FEATURE_NAME/presentation/bloc/${FEATURE_NAME}_bloc.dart
    mkdir -p lib/features/$FEATURE_NAME/presentation/bloc/${FEATURE_NAME}_event.dart
    mkdir -p lib/features/$FEATURE_NAME/presentation/bloc/${FEATURE_NAME}_state.dart
    mkdir -p lib/features/$FEATURE_NAME/presentation/pages/${FEATURE_NAME}_page.dart
    mkdir -p lib/features/$FEATURE_NAME/presentation/widgets/${FEATURE_NAME}_widget.dart
}



# Update pubspec.yaml with common dependencies
cat > pubspec.yaml << EOL
name: $PROJECT_NAME
description: A new Flutter project with Clean Architecture.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  auto_route: ^9.2.2
  firebase_core: ^3.9.0
  logger: ^2.5.0
  flutter_screenutil: ^5.9.3
  flutter_easyloading: ^3.0.5
  easy_localization: ^3.0.7
  injectable: ^2.5.0
  get_it: ^8.0.3
  equatable: ^2.0.7
  flutter_bloc: ^8.1.6
  fluttertoast: ^8.2.10
  local_auth: ^2.3.0
  firebase_messaging: ^15.2.0
  flutter_local_notifications: ^18.0.1
  path_provider: ^2.1.5
  shared_preferences: ^2.3.5
  flutter_secure_storage: ^9.2.4
  flutter_typeahead: ^5.2.0
  animated_toggle_switch: ^0.8.4
  flutter_svg: ^2.0.17
  heroicons: ^0.11.0
  bloc: ^8.1.4
  flutter_slidable: ^3.1.2
  popover: ^0.3.1
  focused_menu: ^1.0.5
  gap: ^3.0.1
  pretty_dio_logger: ^1.4.0
  connectivity_plus: ^6.1.2
  flutter_cache_manager_dio: ^4.0.0
  flutter_cache_manager: ^3.4.1
  dio: ^5.7.0
  built_collection: ^5.1.1
  device_info_plus: ^11.2.2
  intl: ^0.19.0


dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  auto_route_generator: ^9.0.0
  injectable_generator:
  build_runner:
  flutter_gen_runner:
  json_serializable: ^6.9.0

flutter_gen:
  output: lib/app/gen/ # Optional (default: lib/gen/)
  line_length: 80 # Optional (default: 80)

  # Optional
  integrations:
    flutter_svg: true

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/translations/
EOL

# Create example app, core, feature
# create_app
# create_core
create_feature "home"

# Run flutter pub get
echo "Cleaning"
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run easy_localization:generate --source-dir 'assets/translations/' --output-dir 'lib/app'
flutter pub run easy_localization:generate --source-dir 'assets/translations/' --output-dir 'lib/app' --output-file 'locale_keys.g.dart' --format keys



## Create app file

# router folder
mkdir -p lib/app/router/guard
cat > lib/app/router/guard/init_guard.dart << EOL
import 'package:auto_route/auto_route.dart';

typedef IsInitialized = bool Function();

class InitGuard extends AutoRouteGuard {
  InitGuard();

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    resolver.next();
  }
}

EOL

cat > lib/app/router/app_router.dart << EOL
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
// import 'package:openapi/openapi.dart';

//@formatter:off

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  final List<AutoRoute> routes = [
    // AdaptiveRoute(
    //   page: LoginRoute.page,
    //   path: '/LoginRoute',
    //   initial: true,
    // ),
    // AdaptiveRoute(
    //   page: HomeRoute.page,
    //   path: '/HomeRoute',
    // ),
  ];

  @override
  late final List<AutoRouteGuard> guards;

  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  AppRouter({
    required List<AutoRouteGuard> globalGuards,
  }) : guards = globalGuards;
}
EOL

flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs


cat > lib/app/router/router_logging_observer.dart << 'EOL'
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../core/arch/logger/app_logger_impl.dart';
import 'app_router.dart';

class RouterLoggingObserver extends AutoRouterObserver {
  final AppRouter appRouter;

  RouterLoggingObserver({
    required this.appRouter,
  });

  @override
  void didPush(Route route, Route? previousRoute) {
    logger.w(
      'ROUTING New route pushed: ${route.settings.name}, stack${_stack()}',
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    logger.w(
      'ROUTING Route popped: ${route.settings.name}, stack${_stack()}',
    );
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    logger.w(
      'ROUTING Route removed: ${route.settings.name}, stack${_stack()}',
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    logger.w(
      'ROUTING Route replaced to: ${newRoute?.settings.name} '
      'from: ${oldRoute?.settings.name}, stack${_stack()}',
    );
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    logger.w(
      'ROUTING Tab route visited: ${route.name}, stack${_stack()}',
    );
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    logger.w(
      'ROUTING Tab route re-visited: ${route.name}, stack${_stack()}',
    );
  }

  String _stack() => appRouter.routes.map((it) => it.name).toString();
}
EOL

cat > lib/app/router/router_module.dart << EOL
import 'app_router.dart';
import 'guard/init_guard.dart';
import 'router_logging_observer.dart';
abstract class RouterModule {
  AppRouter appRouter() {
    return AppRouter(globalGuards: [InitGuard()]);
  }

  RouterLoggingObserver routerLoggingObserver(
    AppRouter appRouter,
  ) {
    return RouterLoggingObserver(
      appRouter: appRouter,
    );
  }
}
EOL

# services folder
mkdir -p lib/app/services/notification
cat > lib/app/services/notification/background_service.dart << EOL
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../firebase_options.dart';
import 'notiifcation_service.dart';

@pragma('vm:entry-point')
void onNotificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
}

@pragma('vm:entry-point')
Future<void> onBackgroundNotificationHandle(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final notificationService = NotificationService();
  notificationService.onInit();
}
EOL

cat > lib/app/services/notification/notiifcation_service.dart << 'EOL'
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import 'background_service.dart';

@singleton
class NotificationService {
  // Stream subscriptions for handling different notification events
  late final StreamSubscription<RemoteMessage> _onMessageSub;
  late final StreamSubscription<RemoteMessage> _onMessageOpenAppSub;
  late final StreamSubscription<String> _onTokenRefresh;

  // Firebase Messaging instance
  final _messaging = FirebaseMessaging.instance;

  // Local notifications plugin instance
  final _plugin = FlutterLocalNotificationsPlugin();

  // Android notification channel configuration
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  // Dispose method to cancel subscriptions
  @disposeMethod
  void onClose() {
    _onTokenRefresh.cancel();
    _onMessageSub.cancel();
    _onMessageOpenAppSub.cancel();
  }

  // Request notification permissions based on platform
  Future<bool?> onRequestPermission() async {
    if (Platform.isAndroid) {
      return _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
    } else {
      return _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  // Initialization method to set up notifications
  @PostConstruct(preResolve: true)
  Future<void> onInit() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Request permissions for iOS and macOS
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
    } else if (Platform.isAndroid) {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
    }

    // Set foreground notification presentation options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission();

    // Initialize local notifications plugin
    _plugin.initialize(
      InitializationSettings(
          android: const AndroidInitializationSettings('ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestSoundPermission: true,
            requestBadgePermission: true,
            // onDidReceiveLocalNotification: (id, title, body, payload) =>
            //     onHandleNotification(jsonDecode(payload ?? '{}')),
          )),
    );

    // Listen for notification events
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      if (message.notification != null) {}
    });
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        showNotification(message);
      }
    });
    FirebaseMessaging.onBackgroundMessage(onBackgroundNotificationHandle);
  }

  // Register a topic for notifications
  void registerTopic(String fcmToken, String userId) {}

  // Unregister a topic for notifications
  void unregisterTopic(String fcmToken, String userId) {}

  // Unregister a topic using FCM token
  void unregisterTopicFcmtoken(String fcmToken) {}

  // Handle initial message when the app is launched
  Future<void> onHandleInitialMessage() async {
    final lastMessage = await _messaging.getInitialMessage();
    if (lastMessage != null) {}

    final lastNotification = await _plugin.getNotificationAppLaunchDetails();
    if (lastNotification != null &&
        lastNotification.didNotificationLaunchApp &&
        lastNotification.notificationResponse != null) {
      onHandleNotification(
          (jsonDecode(lastNotification.notificationResponse?.payload ?? '{}')
              as Map<String, dynamic>));
    }
  }

  // Get FCM token for the device
  Future<String?> getFcmToken() async {
    if (Platform.isIOS) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) {
        return _messaging.getToken();
      }
    }
    return _messaging.getToken();
  }

  // Handle notification response
  Future<void> onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    switch (notificationResponse.notificationResponseType) {
      case NotificationResponseType.selectedNotification:
        break;
      case NotificationResponseType.selectedNotificationAction:
        debugPrint("type: ${notificationResponse.notificationResponseType}");
        break;
    }
  }

  // Download and save a file from a URL
  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final isIos = Platform.isIOS;
    final directory = isIos
        ? await getTemporaryDirectory()
        : await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  // Show a notification with optional image
  void showNotification(RemoteMessage message) async {
    String largeIconPath = "";
    BigPictureStyleInformation? bigPictureStyleInformation;
    final imageUrl = message.notification?.android?.imageUrl ??
        message.notification?.apple?.imageUrl;

    if (imageUrl != null) {
      final response = await http.get(Uri.parse(imageUrl));
      final base64Image = base64Encode(response.bodyBytes);

      bigPictureStyleInformation = BigPictureStyleInformation(
        ByteArrayAndroidBitmap.fromBase64String(base64Image),
        largeIcon: ByteArrayAndroidBitmap.fromBase64String(base64Image),
      );

      largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon.jpg');
    }

    final DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      attachments: largeIconPath.isNotEmpty
          ? <DarwinNotificationAttachment>[
              DarwinNotificationAttachment(
                largeIconPath,
                hideThumbnail: false,
              )
            ]
          : null,
    );
    _plugin.show(
        0,
        message.notification?.title ?? '',
        message.notification?.body ?? '',
        NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              largeIcon: largeIconPath.isNotEmpty
                  ? FilePathAndroidBitmap(largeIconPath)
                  : null,
              styleInformation: bigPictureStyleInformation,
              importance: channel.importance,
              color: const Color(0xFF434336),
              priority: Priority.high,
            ),
            iOS: darwinNotificationDetails),
        payload: jsonEncode(message.data));
  }

  // Handle notification payload
  void onHandleNotification(Map<String, dynamic> payload) {}
}
EOL


# Create core files
mkdir -p lib/core/error
cat > lib/core/error/failures.dart << EOL
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}
EOL

cat > lib/app/services/biometric_auth.dart << 'EOL'
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

@singleton
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> authenticate() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access this feature',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    return isAuthenticated;
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint(e.toString());
      return <BiometricType>[];
    }
  }

  Future<void> cancelAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
EOL

#util folder

cat > lib/app/util/failure_message_extension.dart << EOL
extension FailureMessageExtension on BuildContext {
  String getApiFailureMessage(ApiFailure failure) {
    switch (failure.failure) {
      case ServerFailure.noNetwork:
        return LocaleKeys.apiFailureNoNetwork.tr();
      case ServerFailure.exception:
        return LocaleKeys.apiFailureUndefined.tr();
      case ServerFailure.unAuthorized:
        return LocaleKeys.apiFailureUnAuthorized.tr();
      case ServerFailure.tooManyRequests:
        return LocaleKeys.apiFailureTooManyRequests.tr();
      case ServerFailure.response:
        return failure.message;
      case ServerFailure.unknown:
        return LocaleKeys.apiFailureUndefined.tr();
    }
  }
}

class ApiFailure implements Failure {
  final ServerFailure failure;
  final int? statusCode;

  final String message;

  ApiFailure(
    this.failure, {
    this.message = '',
    this.statusCode,
  });

  @override
  String toString() {
    return 'ApiFailure{$failure, message: $message, statusCode: $statusCode}';
  }
}

class ApiUndefinedFailure extends ApiFailure {
  ApiUndefinedFailure({
    int? statusCode,
    required String message,
  }) : super(ServerFailure.unknown, message: message, statusCode: statusCode);

  @override
  String toString() {
    return 'ApiUndefinedFailure{failure: $failure, statusCode: $statusCode, message: $message}';
  }
}

class ConnectionFailure extends ApiFailure {
  ConnectionFailure() : super(ServerFailure.noNetwork, message: '');

  @override
  String toString() {
    return 'ConnectionFailure{failure: $failure}';
  }
}

class ApiExceptionFailure extends ApiFailure {
  ApiExceptionFailure({
    required String message,
  }) : super(ServerFailure.exception, message: message);

  @override
  String toString() {
    return 'ApiExceptionFailure{failure: $failure, message: $message}';
  }
}

class ApiUnauthorizedFailure extends ApiFailure {
  ApiUnauthorizedFailure() : super(ServerFailure.unAuthorized, message: '');

  @override
  String toString() {
    return 'ApiUnauthorizedFailure{failure: $failure}';
  }
}

class ApiTooManyRequestsFailure extends ApiFailure {
  ApiTooManyRequestsFailure()
      : super(ServerFailure.tooManyRequests, message: '');

  @override
  String toString() {
    return 'ApiTooManyRequestsFailure{failure: $failure}';
  }
}

class ApiUnknownFailure extends ApiFailure {
  ApiUnknownFailure() : super(ServerFailure.unknown, message: '');

  @override
  String toString() {
    return 'ApiUnknownFailure{failure: $failure}';
  }
}

enum ServerFailure {
  noNetwork,
  exception,
  unAuthorized,
  tooManyRequests,
  response,
  unknown,
}

abstract class Failure {}

EOL

cat > lib/app/util/orientation_extension.dart << EOL
extension OrientationExtension on SystemChrome {
  static Future<void> lockVertical() async =>
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      );

  static Future<void> lockHorizontal() async =>
      SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
      );

  static Future<void> unlock() async => SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );
}
EOL

cat > lib/app/util/orientation_extension.dart << EOL
extension ThemeBrightnessExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  void switchThemeBrightness({
    required ThemeMode currentThemeMode,
  }) {
    var newThemeMode = ThemeMode.system;
    switch (currentThemeMode) {
      case ThemeMode.system:
        {
          if (isDarkMode) {
            newThemeMode = ThemeMode.light;
            break;
          }
          newThemeMode = ThemeMode.dark;
          break;
        }
      case ThemeMode.light:
        {
          newThemeMode = ThemeMode.dark;
          break;
        }
      case ThemeMode.dark:
        {
          newThemeMode = ThemeMode.light;
          break;
        }
    }

    ThemeModeNotifier.of(this).changeTheme(newThemeMode);
  }
}
EOL

cat > lib/app/util/ui_utils_extension.dart << EOL
extension UiUtilExtension on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  Size get screenSize => MediaQuery.sizeOf(this);

  double get statusBarHeight => MediaQuery.paddingOf(this).top;
}
EOL

cat > lib/app/util/utc_to_local.dart << EOL
@singleton
class UtcToLocal {
  String convertUtcToLocal(DateTime dateTime, {String? newPattern}) {
    DateTime localTime = dateTime.toLocal();

    // Format sử dụng intl
    DateFormat formatter = DateFormat(newPattern);
    String formattedTime = formatter.format(localTime);
    return formattedTime;
  }
}
EOL

cat > lib/app/initialization.dart << EOL
//@formatter:off
class Initialization {
  static final Initialization _instance = Initialization._privateConstructor();

  static Initialization get I => _instance;

  Initialization._privateConstructor();

  Future<void> initApp() async {
    initializeDi(GetIt.I);
    logger.d('APP Init: done');
  }
}
EOL

cat > lib/app/my_app.dart << EOL
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        //BlocProvider(create: (context) => app.getMyChannelsBloc()),
        //BlocProvider(create: (context) => app.getNotificationBloc()),
        //BlocProvider(create: (context) => app.getNotificationContentBloc()),
        //BlocProvider(create: (context) => app.getNotificationToDoBloc()),
        //BlocProvider(create: (context) => app.getToDoDetailBloc()),
        //BlocProvider(create: (context) => app.getToDoList()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) {
          return ThemeModeSwitcher(
            builder: (context, themeMode, _) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                scaffoldMessengerKey: scaffoldMessengerKey,
                builder: EasyLoading.init(),
                scrollBehavior: const CupertinoScrollBehavior(),
                theme: createLightTheme(),
                themeMode: themeMode,
                routerConfig: appRouter.config(),
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                // onGenerateTitle: (context) => S.of(context).title,
              );
            },
          );
        },
      ),
    );
  }
}

EOL

## Core folder

#core/arch
mkdir -p lib/core/arch/logger
cat > lib/core/arch/logger/app_logger_impl.dart << EOL
AppLogger get logger => AppLoggerImpl.I;

class AppLoggerImpl extends AppLogger {
  late Logger _logger;

  @visibleForTesting
  static bool recordCrashlyticsError = true;

  AppLoggerImpl._() {
    _logger = Logger();
  }

  static final AppLoggerImpl _instance = AppLoggerImpl._();

  static AppLoggerImpl get I => _instance;

  @override
  void crash({String reason = '', Object? error, StackTrace? stackTrace}) {
    e(reason, error: error, stackTrace: stackTrace);
    if (recordCrashlyticsError) {
      CrashlyticsUtil.recordError(
        reason: reason,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void d(
    Object message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.d(message, time: time, error: error, stackTrace: stackTrace);
  }

  @override
  void e(
    Object message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(message, time: time, error: error, stackTrace: stackTrace);
  }

  @override
  void f(
    Object message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(message, time: time, error: error, stackTrace: stackTrace);
  }

  @override
  void i(
    Object message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.i(message, time: time, error: error, stackTrace: stackTrace);
  }

  @override
  void t(
    Object message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.t(message, time: time, error: error, stackTrace: stackTrace);
  }

  @override
  void w(
    Object message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.w(message, time: time, error: error, stackTrace: stackTrace);
  }
}
EOL

cat > lib/core/arch/logger/app_logger.dart << EOL
abstract class AppLogger {
  void f(
    Object message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  });

  void i(
    Object message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  });

  void t(
    Object message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  });

  void e(
    Object message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  });

  void w(
    Object message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  });

  void d(
    Object message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  });

  void crash({String reason = '', Object? error, StackTrace? stackTrace});
}
EOL

cat > lib/core/arch/logger/crashlytics_util.dart << EOL
class CrashlyticsUtil {
  static void recordError({
    String reason = '',
    Object? error,
    StackTrace? stackTrace,
  }) {
    //TODO Add here crash recognition system
    // FirebaseCrashlytics.instance.recordError(
    //   error,
    //   stackTrace,
    //   printDetails: true,
    //   reason: reason,
    // );
  }
}
EOL

# widget/common
mkdir -p lib/core/arch/widget/common
cat > lib/core/arch/widget/common/clickable_widget.dart << EOL
class ClickableWidget extends StatelessWidget {
  const ClickableWidget({
    required this.child,
    this.onTap,
    this.color = Colors.transparent,
    this.splashColor,
    this.borderRadius,
    this.borderRadiusInk,
    this.elevation = 0,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color? splashColor;
  final double elevation;
  final BorderRadiusGeometry? borderRadius;
  final BorderRadius? borderRadiusInk;

  @override
  Widget build(BuildContext context) => Material(
        color: color,
        elevation: elevation,
        borderRadius: borderRadius ?? borderRadiusInk,
        child: InkWell(
          borderRadius: borderRadiusInk ?? BorderRadius.circular(0),
          splashColor: splashColor ??
              Theme.of(context).primaryColor.withAlpha((0.03 * 255).toInt()),
          highlightColor: splashColor ??
              Theme.of(context).primaryColor.withAlpha((0.03 * 255).toInt()),
          onTap: onTap,
          child: child,
        ),
      );
}
EOL

cat > lib/core/arch/widget/common/ensure_visible.dart << EOL

///
/// Helper class that ensures a Widget is visible when it has the focus
/// For example, for a TextFormField when the keyboard is displayed
///
/// How to use it:
///
/// In the class that implements the Form,
///   Instantiate a FocusNode
///   FocusNode _focusNode = new FocusNode();
///
/// In the build(BuildContext context), wrap the TextFormField as follows:
///
///   new EnsureVisibleWhenFocused(
///     focusNode: _focusNode,
///     child: new TextFormField(
///       ...
///       focusNode: _focusNode,
///     ),
///   ),
///
/// Initial source code written by Collin Jackson.
/// Extended (see highlighting) to cover the case when the keyboard
/// is dismissed and the
/// user clicks the TextFormField/TextField which still has the focus.
///
class EnsureVisibleWhenFocused extends StatefulWidget {
  /// The node we will monitor to determine if the child is focused
  final FocusNode focusNode;

  /// The child widget that we are wrapping
  final Widget child;

  /// The curve we will use to scroll ourselves into view.
  ///
  /// Defaults to Curves.ease.
  final Curve curve;

  /// The duration we will use to scroll ourselves into view
  ///
  /// Defaults to 100 milliseconds.
  final Duration duration;

  /// The alignment will override the default alignment behaviour
  ///
  /// No default value.
  final double? alignment;

  const EnsureVisibleWhenFocused({
    required this.child,
    required this.focusNode,
    super.key,
    this.curve = Curves.easeIn,
    this.duration = const Duration(milliseconds: 100),
    this.alignment,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EnsureVisibleWhenFocusedState createState() =>
      _EnsureVisibleWhenFocusedState();
}

///
/// We implement the WidgetsBindingObserver to be notified of any change
/// to the window metrics
///
class _EnsureVisibleWhenFocusedState extends State<EnsureVisibleWhenFocused>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_ensureVisible);
    WidgetsBinding.instance.addObserver(this);
  }

  ///
  /// This routine is invoked when the window metrics have changed.
  /// This happens when the keyboard is open or dismissed, among others.
  /// It is the opportunity to check if the field has the focus
  /// and to ensure it is fully visible in the viewport when
  /// the keyboard is displayed
  ///
  @override
  void didChangeMetrics() {
    if (widget.focusNode.hasFocus) {
      _ensureVisible();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.focusNode.removeListener(_ensureVisible);
    super.dispose();
  }

  ///
  /// This routine waits for the keyboard to come into view.
  /// In order to prevent some issues if the Widget is dismissed in the
  /// middle of the loop, we need to check the "mounted" property
  ///
  /// This method was suggested by Peter Yuen (see discussion).
  ///
  Future<void> _keyboardToggled() async {
    if (mounted) {
      final edgeInsets = MediaQuery.of(context).viewInsets;
      while (mounted && MediaQuery.of(context).viewInsets == edgeInsets) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }

    return;
  }

  Future<void> _ensureVisible() async {
    // Wait for the keyboard to come into view
    await Future.any([
      Future.delayed(const Duration(milliseconds: 300)),
      _keyboardToggled(),
    ]);

    // No need to go any further if the node has not the focus
    if (!widget.focusNode.hasFocus) {
      return;
    }

    // Find the object which has the focus
    if (!mounted) {
      return;
    }
    // ignore: avoid-non-null-assertion
    final object = context.findRenderObject()!;
    final viewport = RenderAbstractViewport.of(object);

    // Get the Scrollable state (in order to retrieve its offset)
    // ignore: avoid-non-null-assertion
    final scrollableState = Scrollable.of(context);

    // Get its offset
    final position = scrollableState.position;
    late double alignment;

    if (position.pixels > viewport.getOffsetToReveal(object, 0).offset) {
      // Move down to the top of the viewport
      alignment = 0.0;
    } else if (position.pixels < viewport.getOffsetToReveal(object, 1).offset) {
      // Move up to the bottom of the viewport
      alignment = 1.0;
    } else {
      // No scrolling is necessary to reveal the child
      return;
    }

    //ignore: unawaited_futures
    position.ensureVisible(
      object,
      alignment: widget.alignment ?? alignment,
      duration: widget.duration,
      curve: widget.curve,
    );
  }
}
EOL

cat > lib/core/arch/widget/common/scroll_root_max.dart <<EOL

class ScrollRootMax extends StatelessWidget {
  const ScrollRootMax({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        context,
        viewportConstraints,
      ) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
              minWidth: viewportConstraints.maxWidth,
            ),
            child: IntrinsicHeight(
              child: child,
            ),
          ),
        );
      },
    );
  }
}
EOL

cat > lib/core/arch/widget/common/scroll_root_min.dart <<EOL
class ScrollRootMin extends StatelessWidget {
  const ScrollRootMin({
    required this.child,
    this.physics,
    super.key,
  });

  final Widget child;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        context,
        viewportConstraints,
      ) {
        return SingleChildScrollView(
          physics: physics ?? const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
EOL

cat > lib/core/arch/widget/common/theme_switcher.dart <<EOL
class ThemeModeSwitcher extends StatefulWidget {
  final Widget Function(BuildContext, ThemeMode, Widget?) builder;
  final ThemeMode initialThemeMode;

  const ThemeModeSwitcher({
    required this.builder,
    this.initialThemeMode = ThemeMode.system,
    super.key,
  });

  @override
  State<ThemeModeSwitcher> createState() => _ThemeModeSwitcherState();
}

class _ThemeModeSwitcherState extends State<ThemeModeSwitcher> {
  late final _themeNotifier = ValueNotifier<ThemeMode>(widget.initialThemeMode);

  @override
  Widget build(BuildContext context) {
    return ThemeModeNotifier(
      notifier: _themeNotifier,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeNotifier,
        builder: widget.builder,
      ),
    );
  }
}

class ThemeModeNotifier extends InheritedWidget {
  final ValueNotifier<ThemeMode> notifier;

  const ThemeModeNotifier({
    required this.notifier,
    required super.child,
    super.key,
  });

  void changeTheme(ThemeMode themeMode) {
    notifier.value = themeMode;
  }

  static ThemeModeNotifier of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeModeNotifier>()!;
  }

  @override
  bool updateShouldNotify(covariant ThemeModeNotifier oldWidget) {
    if (notifier.value != oldWidget.notifier.value) {
      return true;
    }
    return false;
  }
}
EOL

cat > lib/core/arch/widget/common/toast.dart <<EOL
class CustomToast {
  static void showDebugToast() {
    Fluttertoast.showToast(
      msg: 'Under development',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16,
    );
  }

  static void showToast(String msg, {Toast toastLength = Toast.LENGTH_LONG}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black54,
      timeInSecForIosWeb: 5,
      fontSize: 16,
    );
  }
}
EOL

cat > lib/core/arch/widget/text_form_field.dart <<EOL
class TextFormFieldCustom extends StatelessWidget {
  final TextEditingController? textController;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final InputDecoration? decoration;
  final String? labelText;
  final String? hintText;
  final bool? obscureText;
  final Widget? suffixIcon;
  final TextStyle? style;
  const TextFormFieldCustom({
    super.key,
    this.textController,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
    this.validator,
    this.decoration,
    this.labelText,
    this.hintText,
    this.obscureText,
    this.suffixIcon,
    this.style,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: style,
      controller: textController,
      obscureText: obscureText ?? false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: focusNode,
      onFieldSubmitted: (_) {
        // FocusScope.of(context).requestFocus(passFocus);
      },
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return LocaleKeys.emptyValidation.tr();
        }
        return null;
      },
      decoration: decoration ??
          InputDecoration(
              contentPadding: EdgeInsets.all(12),
              labelText: labelText,
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: suffixIcon),
    );
  }
}
EOL

cat > lib/core/arch/widget/text_form_field.dart <<EOL
class TextFormFieldCustom extends StatelessWidget {
  final TextEditingController? textController;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final InputDecoration? decoration;
  final String? labelText;
  final String? hintText;
  final bool? obscureText;
  final Widget? suffixIcon;
  final TextStyle? style;
  const TextFormFieldCustom({
    super.key,
    this.textController,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
    this.validator,
    this.decoration,
    this.labelText,
    this.hintText,
    this.obscureText,
    this.suffixIcon,
    this.style,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: style,
      controller: textController,
      obscureText: obscureText ?? false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: focusNode,
      onFieldSubmitted: (_) {
        // FocusScope.of(context).requestFocus(passFocus);
      },
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return LocaleKeys.emptyValidation.tr();
        }
        return null;
      },
      decoration: decoration ??
          InputDecoration(
              contentPadding: EdgeInsets.all(12),
              labelText: labelText,
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: suffixIcon),
    );
  }
}
EOL

cat > lib/core/di/register_di.dart <<EOL
//@formatter:off
void registerApp(GetIt getIt) {
  final routerModule = _RouterModule();

  getIt
    ..registerSingleton<AppRouter>(
      routerModule.appRouter(),
    )
    ..registerFactory<RouterLoggingObserver>(
      () => routerModule.routerLoggingObserver(getIt.get<AppRouter>()),
    );
}

//void registerBloc(GetIt getIt) {
  //getIt.registerFactory<MyChannelsBloc>(
   // () => MyChannelsBloc(UnMyChannelsState()),
  //);
//}

//void registerOpenApi(GetIt getIt) {
  //final openapi = Openapi(
    //dio: DioFactory().dio,
  //);

  //getIt.registerSingleton<AuthApi>(
    //openapi.getAuthApi(),
  //);
//}

//Injectation
//UtcToLocal utcToLocal() => locator.get();

//Get It
AppRouter appRouter() => GetIt.I<AppRouter>();

class _RouterModule extends RouterModule {}
EOL

cat > lib/core/di/injection.dart <<EOL

import 'injection.config.dart';

final locator = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies() => locator.init();

void initializeDi(GetIt getIt) {
  registerApp(getIt);
  registerOpenApi(getIt);
  registerBloc(getIt);
}

final AppRouter appRouter = locator<AppRouter>();
EOL

cat > lib/core/constans.dart <<EOL
class Constants {
  //GET https://newsapi.org/v2/everything?q=bitcoin&api
  //top-headlines?country=us
  static const String BASE_URL = "http://60.251.54.95:8031";
  static const String BASE_URL_GATEWAY = "https://api-gateway.thieuhoa.com.vn";

  static const String key = "b4f4a30a2e6546a5897afa877c39ec15";
  static const String empty = "";
  static const int zero = 0;
  static const String token = "SEND TOKEN HERE";
  static const int apiTimeOut = 60000;
  static const DAY_FORMAT = 'dd/MM/yyyy HH:mm';
  static const DAY_MONTH_FORMAT = 'dd/MM';
  static const HOUR_FORMAT = 'HH:mm';
  static const EN_US = 'en';
  static const ZH_CN = 'zh';

  static const REGEX_NUMBER_PHONE = r'^[0-9]+$';

  static const LIMIT = 20;

  static const ICON_VOLUNTEER =
      "https://thieuhoa.com.vn/v2/img/svg/volunteer_activism1.svg";
  static const ICON_CARGO_TRUCK =
      "https://thieuhoa.com.vn/v2/img/svg/cargo-truck-1.svg";
  static const ICON_CART_ON_DELIVERY =
      "https://thieuhoa.com.vn/v2/img/svg/cash-on-delivery1.svg";
  static const ICON_VERIFIED =
      "https://thieuhoa.com.vn/v2/img/svg/verified_user1.svg";

  static const PLACEHOLDER =
      "https://i.pinimg.com/736x/29/b8/d2/29b8d250380266eb04be05fe21ef19a7.jpg";

  static const PLACEHOLDER_CACHE_IMAGE =
      "https://developers.google.com/static/maps/documentation/maps-static/images/error-image-generic.png";

  static const PHONE_NUMBER = 18009246;
}
EOL

mkdir -p lib/core/arch/share_preference
cat > lib/core/arch/share_preference/base_preference.dart <<EOL
@injectable
class BasePreferences {
  Future<T> get<T>(String key, T defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    T? result;

    switch (defaultValue.runtimeType) {
      case const (String):
        result = prefs.getString(key) as T?;
      case const (bool):
        result = prefs.getBool(key) as T?;
      case const (int):
        result = prefs.getInt(key) as T?;
      case const (double):
        result = prefs.getDouble(key) as T?;
      case const (List<String>):
        result = prefs.getStringList(key) as T?;
    }
    return result ?? defaultValue;
  }

  Future<void> put<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();

    switch (value.runtimeType) {
      case const (String):
        await prefs.setString(key, value as String);
      case const (bool):
        await prefs.setBool(key, value as bool);
      case const (double):
        await prefs.setDouble(key, value as double);
      case const (int):
        await prefs.setInt(key, value as int);
      case const (List<String>):
        await prefs.setStringList(key, value as List<String>);
    }
  }

  Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> removePrefByKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  Future<void> reload() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
  }
}
EOL

cat > lib/core/arch/share_preference/preferences_keys.dart <<EOL
class PrefsKeys {
  static const String kCacheWriteTimestampKey = 'PREF_CACHE_WRITE_TIMESTAMP';
  static const String kFCMTokenKey = 'PREF_FCM_TOKEN_KEY';
  static const String kJWTUser = 'PREF_JWT_USER';
  static const String kBiometric = 'PREF_BIOMETRIC_AUTH';
  static const String kChannelKeySearch = 'PREF_CHANNEL_KEYSEARCH';
  static const String kNotificationKeySearch = 'PREF_NOTIFICATION_KEYSEARCH';
  static const String kTodoKeySearch = 'PREF_TODO_KEYSEARCH';
}
EOL

cat > lib/core/arch/share_preference/preferences_source_impl.dart <<EOL
@singleton
class PreferencesSourceImpl implements PreferencesSource {
  final BasePreferences _preferences;
  late final SharedPreferences sharedPreferences;

  @PostConstruct(preResolve: true)
  Future<void> onInitService() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  PreferencesSourceImpl(this._preferences);

  @override
  Future<int> getCacheTimestamp() async {
    return _preferences.get<int>(PrefsKeys.kCacheWriteTimestampKey, -1);
  }

  @override
  Future<String> getFCMToken() {
    return _preferences.get<String>(PrefsKeys.kFCMTokenKey, '');
  }

  @override
  Future<void> saveCacheTimestamp(int value) async {
    await _preferences.put<int>(PrefsKeys.kCacheWriteTimestampKey, value);
  }

  @override
  Future<void> saveFCMToken(String value) async {
    await _preferences.put<String>(PrefsKeys.kFCMTokenKey, value);
  }

  @override
  Future<bool> getBiometric() {
    return _preferences.get<bool>(PrefsKeys.kBiometric, false);
  }

  @override
  Future<String> getJWTUser() {
    return _preferences.get<String>(PrefsKeys.kJWTUser, '');
  }

  @override
  Future<String> getChannelKeySearch() async {
    return _preferences.get<String>(PrefsKeys.kChannelKeySearch, "");
  }

  @override
  Future<String> getNotificationKeySearch() async {
    return _preferences.get<String>(PrefsKeys.kNotificationKeySearch, "");
  }

  @override
  Future<String> getTodoKeySearch() async {
    return _preferences.get<String>(PrefsKeys.kTodoKeySearch, "");
  }

  @override
  Future<void> saveBiometric(bool value) async {
    await _preferences.put<bool>(PrefsKeys.kBiometric, value);
  }

  @override
  Future<void> saveJWTUser(String value) async {
    await _preferences.put<String>(PrefsKeys.kJWTUser, value);
  }

  @override
  Future<void> saveChannelKeySearch(String value) async {
    await _preferences.put<String>(PrefsKeys.kChannelKeySearch, value);
  }

  @override
  Future<void> saveNotificationKeySearch(String value) async {
    await _preferences.put<String>(PrefsKeys.kNotificationKeySearch, value);
  }

  @override
  Future<void> saveTodoKeySearch(String value) async {
    await _preferences.put<String>(PrefsKeys.kTodoKeySearch, value);
  }
}
EOL

cat > lib/core/arch/share_preference/preferences_source.dart <<EOL
abstract class PreferencesSource {
  Future<int> getCacheTimestamp();

  Future<String> getFCMToken();

  Future<bool> getBiometric();

  Future<String> getJWTUser();

  Future<String> getChannelKeySearch();

  Future<String> getNotificationKeySearch();

  Future<String> getTodoKeySearch();

  Future<void> saveCacheTimestamp(int value);

  Future<void> saveFCMToken(String value);

  Future<void> saveBiometric(bool value);

  Future<void> saveJWTUser(String value);

  Future<void> saveChannelKeySearch(String value);

  Future<void> saveNotificationKeySearch(String value);

  Future<void> saveTodoKeySearch(String value);
}
EOL

mkdir lib/core/arch/secure_storage
cat > lib/core/arch/secure_storage/secure_storage_keys.dart << EOL
class SecureStorageKeys {
  static const String kSecretKeyCipher = 'SS_SECRET_KEY_CIPHER';
  static const String kAccessToken = 'ACCESS_TOKEN';
  static const String kRefreshToken = 'REFRESH_TOKEN';
}
EOL


cat > lib/core/arch/secure_storage/secure_storage_source_impl.dart << EOL
class SecureStorageSourceImpl implements SecureStorageSource {
  FlutterSecureStorage? _secureStorage;

  SecureStorageSourceImpl() {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
  }

  @override
  Future<void> clear() async {
    await _secureStorage?.deleteAll();
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _secureStorage?.delete(
        key: key,
      );
    } catch (e, trace) {
      logger.crash(
        reason: 'secure_storage_clear',
        error: e,
        stackTrace: trace,
      );
    }
  }

  @override
  Future<String> read(String key) async {
    try {
      return await _secureStorage?.read(key: key) ?? '';
    } catch (e, trace) {
      logger.crash(
        reason: 'secure_storage_read',
        error: e,
        stackTrace: trace,
      );
      return '';
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _secureStorage?.write(key: key, value: value);
    } catch (e, trace) {
      logger.crash(
        reason: 'secure_storage_write',
        error: e,
        stackTrace: trace,
      );
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      final exist = await _secureStorage?.containsKey(key: key);
      if (exist != null) {
        return exist;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
EOL
cat > lib/core/arch/secure_storage/secure_storage_source.dart <<EOL
abstract class SecureStorageSource {
  Future<void> write(String key, String value);

  Future<void> delete(String key);

  Future<String> read(String key);

  Future<void> clear();

  Future<bool> containsKey(String key);
}
EOL

mkdir -p lib/data/source/network
cat > lib/data/source/network/dio_factory.dart <<EOL
const String applicationJson = "application/json";
const String contentType = "content-type";
const String accept = "accept";
const String authorization = "authorization";
const String defaultLanguage = "language";
const key = 'customCacheKey';

@lazySingleton
class DioFactory {
  Dio? _dio;
  CacheManager? _cacheManager; // Replace DioCacheManager with CacheManager

  Dio get dio {
    _dio ??= getDio();
    return _dio!;
  }

  Dio getDio() {
    Dio dio = Dio();

    _cacheManager = CacheManager(Config(
      key,
      stalePeriod: const Duration(hours: 24),
      maxNrOfCacheObjects: 0,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileSystem: IOFileSystem(key),
      fileService: HttpFileService(),
    )); // Initialize CacheManager

    Map<String, String> headers = {
      contentType: applicationJson,
      accept: applicationJson,
      defaultLanguage: "en",
    };

    dio.options = BaseOptions(
      baseUrl: Constants.BASE_URL,
      headers: headers,
      connectTimeout: const Duration(seconds: Constants.apiTimeOut),
      receiveTimeout: const Duration(seconds: Constants.apiTimeOut),
      sendTimeout: const Duration(seconds: Constants.apiTimeOut),
    );

    dio.interceptors.add(
        RetryInterceptor(_cacheManager, dio: dio)); // Add the retry interceptor

    if (!kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
        ),
      );
    }

    return dio;
  }
}

// Retry Interceptor that retries until successful connection
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final Connectivity _connectivity = Connectivity();
  final CacheManager? _cacheManager;

  RetryInterceptor(this._cacheManager, {required this.dio});

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      try {
        // Keep retrying until a connection is established and request succeeds
        final response = await _retryUntilConnected(err.requestOptions);
        return handler.resolve(response.data);
      } catch (e) {
        return handler.reject(err);
      }
    } else {
      return handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    // Retry for connection timeout or unknown errors (like network issues)
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.unknown ||
        err.type == DioExceptionType.connectionError;
  }

  Future<Result<Response>> _retryUntilConnected(
      RequestOptions requestOptions) async {
    while (true) {
      // Check connectivity
      final List<ConnectivityResult> connectivityResult =
          await (_connectivity.checkConnectivity());
      debugPrint("$connectivityResult");
      // If connected, try to make the request
      if (connectivityResult.contains(ConnectivityResult.none)) {
        try {
          final options = Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          );
          // Use CacheManager to handle caching
          final fileInfo =
              await _cacheManager!.getFileFromCache(requestOptions.path);
          if (fileInfo != null && fileInfo.validTill.isAfter(DateTime.now())) {
            final res = Response(
              requestOptions: requestOptions,
              data: fileInfo.file.readAsStringSync(),
              statusCode: 200,
            );

            return Result.success(res);
          } else {
            final response = await dio.request(
              requestOptions.path,
              data: requestOptions.data,
              queryParameters: requestOptions.queryParameters,
              options: options,
            );
            await _cacheManager!.putFile(
              requestOptions.path,
              response.data,
              fileExtension: 'json',
            );
            return Result.success(response);
          }
        } on DioException catch (error) {
          // Handle Dio specific errors
          final errorHandler = ErrorHandler.handle(error);
          return Result.failure(errorHandler.failure); // Return failure
        } catch (error) {
          // Handle other exceptions
          return Result.failure(
              ApiFailure(ResponseCode.DEFAULT, error.toString()));
        }
      }

      // Wait before checking connectivity again
      await Future.delayed(const Duration(seconds: 1)); // Retry every second
    }
  }
}
EOL

mkdir -p lib/data/source/network
cat > lib/data/source/network/error_handle.dart <<EOL
class ApiFailure extends Failure {
  final int statusCode;
  final String message;

  ApiFailure(this.statusCode, this.message);
}

class ErrorHandler implements Exception {
  late Failure failure;

  ErrorHandler.handle(dynamic error) {
    if (error is DioException) {
      // dio error so its an error from response of the API or from dio itself
      failure = _handleError(error);
    } else {
      // default error
      failure = DataSource.DEFAULT.getFailure();
    }
  }
}

Failure _handleError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return DataSource.CONNECT_TIMEOUT.getFailure();
    case DioExceptionType.sendTimeout:
      return DataSource.SEND_TIMEOUT.getFailure();
    case DioExceptionType.receiveTimeout:
      return DataSource.RECIEVE_TIMEOUT.getFailure();
    case DioExceptionType.badResponse:
      if (error.response != null &&
          error.response?.statusCode != null &&
          error.response?.statusMessage != null) {
        return ApiFailure(error.response?.statusCode ?? 0,
            error.response?.data["message"] ?? "");
      } else {
        return DataSource.DEFAULT.getFailure();
      }
    case DioExceptionType.cancel:
      return DataSource.CANCEL.getFailure();
    default:
      return DataSource.DEFAULT.getFailure();
  }
}

enum DataSource {
  SUCCESS,
  NO_CONTENT,
  BAD_REQUEST,
  FORBIDDEN,
  UNAUTORISED,
  NOT_FOUND,
  INTERNAL_SERVER_ERROR,
  CONNECT_TIMEOUT,
  CANCEL,
  RECIEVE_TIMEOUT,
  SEND_TIMEOUT,
  CACHE_ERROR,
  NO_INTERNET_CONNECTION,
  DEFAULT
}

extension DataSourceExtension on DataSource {
  Failure getFailure() {
    switch (this) {
      case DataSource.SUCCESS:
        return ApiFailure(ResponseCode.SUCCESS, LocaleKeys.success.tr());
      case DataSource.NO_CONTENT:
        return ApiFailure(ResponseCode.NO_CONTENT, LocaleKeys.no_content.tr());
      case DataSource.BAD_REQUEST:
        return ApiFailure(
            ResponseCode.BAD_REQUEST, LocaleKeys.bad_request_error.tr());
      case DataSource.FORBIDDEN:
        return ApiFailure(
            ResponseCode.FORBIDDEN, LocaleKeys.forbidden_error.tr());
      case DataSource.UNAUTORISED:
        return ApiFailure(
            ResponseCode.UNAUTORISED, LocaleKeys.unauthorized_error.tr());
      case DataSource.NOT_FOUND:
        return ApiFailure(
            ResponseCode.NOT_FOUND, LocaleKeys.not_found_error.tr());
      case DataSource.INTERNAL_SERVER_ERROR:
        return ApiFailure(ResponseCode.INTERNAL_SERVER_ERROR,
            LocaleKeys.internal_server_error.tr());
      case DataSource.CONNECT_TIMEOUT:
        return ApiFailure(
            ResponseCode.CONNECT_TIMEOUT, LocaleKeys.timeout_error.tr());
      case DataSource.CANCEL:
        return ApiFailure(ResponseCode.CANCEL, "");
      case DataSource.RECIEVE_TIMEOUT:
        return ApiFailure(
            ResponseCode.RECIEVE_TIMEOUT, LocaleKeys.timeout_error.tr());
      case DataSource.SEND_TIMEOUT:
        return ApiFailure(
            ResponseCode.SEND_TIMEOUT, LocaleKeys.timeout_error.tr());
      case DataSource.CACHE_ERROR:
        return ApiFailure(
            ResponseCode.CACHE_ERROR, LocaleKeys.cache_error.tr());
      case DataSource.NO_INTERNET_CONNECTION:
        return ApiFailure(ResponseCode.NO_INTERNET_CONNECTION,
            LocaleKeys.no_internet_error.tr());
      case DataSource.DEFAULT:
        return ApiFailure(ResponseCode.DEFAULT, LocaleKeys.default_error.tr());
    }
  }
}

class ResponseCode {
  static const int SUCCESS = 200; // success with data
  static const int NO_CONTENT = 201; // success with no data (no content)
  static const int BAD_REQUEST = 400; // failure, API rejected request
  static const int UNAUTORISED = 401; // failure, user is not authorised
  static const int FORBIDDEN = 403; //  failure, API rejected request
  static const int INTERNAL_SERVER_ERROR = 500; // failure, crash in server side
  static const int NOT_FOUND = 404; // failure, not found

  // local status code
  static const int CONNECT_TIMEOUT = -1;
  static const int CANCEL = -2;
  static const int RECIEVE_TIMEOUT = -3;
  static const int SEND_TIMEOUT = -4;
  static const int CACHE_ERROR = -5;
  static const int NO_INTERNET_CONNECTION = -6;
  static const int DEFAULT = -7;
}

class ApiInternalStatus {
  static const int SUCCESS = 200;
  static const int FAILURE = 400;
}

class Result<T> {
  final T? _data;
  final Failure? _failure;

  bool get isSuccess => _failure == null;

  Result.success(this._data) : _failure = null;
  Result.failure(this._failure) : _data = null;

  T get data {
    if (!isSuccess) {
      throw Exception("No data when the result is a failure.");
    }
    return _data!;
  }

  Failure get failure {
    if (isSuccess) {
      throw Exception("No failure when the result is successful.");
    }
    return _failure!;
  }
}
EOL




# Update main.dart
cat > lib/main.dart << EOL
import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_initialization.dart';
import 'app/codegen_loader.g.dart';
import 'app/util/extension/orientation_extension.dart';
import 'core/arch/logger/app_logger_impl.dart';
import 'core/di/injection.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  unawaited(
    runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        await EasyLocalization.ensureInitialized();
        await Initialization.I.initApp();
        await OrientationExtension.lockVertical();
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        await configureDependencies();
        runApp(EasyLocalization(
            supportedLocales: [Locale('en'), Locale('zh')],
            path:
                'assets/translations/', // <-- change the path of the translation files
            assetLoader: CodegenLoader(),
            child: const App()));
      },
      _onError,
    )?.catchError(
      (error, stackTrace) {
        _onError(error, stackTrace);
        exit(-1);
      },
    ),
  );
}

Future<void> _onError(dynamic error, dynamic stackTrace) async {
  logger.crash(error: error, stackTrace: stackTrace, reason: 'main');
}
EOL

echo "Clean Architecture project '$PROJECT_NAME' has been created successfully!"
echo "Directory structure and base files have been generated."
echo "Don't forget to:"
echo "1. Review and customize the generated files"
echo "2. Add your feature-specific implementations"
echo "3. Set up your dependency injection in lib/di/injection_container.dart"
echo "4. Update the README.md with project-specific information"