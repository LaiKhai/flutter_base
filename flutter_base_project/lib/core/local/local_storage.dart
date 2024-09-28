import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String keyLanguageCode = '_languageCode';
const String keyFirstUserApp = '_firstUseApp';
// const String keyAccessToken = "_accessToken";
// const String keyRefreshToken = "_refreshToken";
// const String keyUserId = '_userId';
// const String keyUserRole = '_userId';
// const String keyPermissions = '_permission';
// const String keyVerificationId = '_verificationId';
// const String keyResendToken = '_resendToken';
// const String keyUID = '_uid';
// const String keyRefCode = '_refCode';
// const String keyPassword = '_password';

const String keyFCMToken = '_fcmToken';
const String keyPhoneNumber = '_phoneNumber';
const String keyKeyWord = '_keyWord';
const String keyBound = '_keyBound';

abstract class LocalStorage {
  Future<void> cacheLanguageCode(String language);
  Future<void> setFCMToken(String fcmToken);

  Future<void> setPhoneNumber(String phoneNumber);

  Future<void> setKeyWord(String keyWord);

  Future<void> setIsBound(bool isBound);

  bool get isBound;

  String get fcmToken;

  String get phoneNumber;

  String get keyword;

  Future<void> clear();
}

@Injectable(
  as: LocalStorage,
)
class LocalStorageImpl extends LocalStorage {
  late final FlutterSecureStorage _flutterSecureStorage;
  late final SharedPreferences sharedPreferences;

  LocalStorageImpl();

  @PostConstruct(preResolve: true)
  Future<void> onInitService() async {
    // _flutterSecureStorage = FlutterSecureStorage(
    //     aOptions: AndroidOptions(encryptedSharedPreferences: true),
    //     iOptions:
    //         const IOSOptions(accessibility: KeychainAccessibility.first_unlock));

    sharedPreferences = await SharedPreferences.getInstance();
    final isFirstUes = sharedPreferences.getBool(keyFirstUserApp) ?? false;
    if (!isFirstUes) {
      sharedPreferences.setBool(keyFirstUserApp, true);
      await _flutterSecureStorage.deleteAll();
    }
  }

  @override
  Future<void> clear() {
    sharedPreferences.clear();
    sharedPreferences.setBool(keyFirstUserApp, true);
    return _flutterSecureStorage.deleteAll();
  }

  @override
  Future<void> setFCMToken(String fcmToken) async {
    // TODO: implement setFCMToken
    await sharedPreferences.setString(keyFCMToken, fcmToken);
  }

  @override
  Future<void> setIsBound(bool isBound) async {
    // TODO: implement setIsBound
    await sharedPreferences.setBool(keyBound, isBound);
  }

  @override
  Future<void> setKeyWord(String keyWord) async {
    // TODO: implement setKeyWord
    await sharedPreferences.setString(keyKeyWord, keyWord);
  }

  @override
  Future<void> setPhoneNumber(String phoneNumber) async {
    // TODO: implement setPhoneNumber
    await sharedPreferences.setString(keyPhoneNumber, phoneNumber);
  }

  @override
  Future<void> cacheLanguageCode(String language) async {
    await sharedPreferences.setString(keyLanguageCode, language);
  }

  @override
  // TODO: implement fcmToken
  String get fcmToken => sharedPreferences.getString(keyFCMToken) ?? '';

  @override
  // TODO: implement isBound
  bool get isBound => sharedPreferences.getBool(keyBound) ?? false;
  @override
  // TODO: implement keyword
  String get keyword => sharedPreferences.getString(keyKeyWord) ?? '';

  @override
  // TODO: implement phoneNumber
  String get phoneNumber => sharedPreferences.getString(keyPhoneNumber) ?? '';
}
