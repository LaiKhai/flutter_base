import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  @factoryMethod
  Future<bool> get isConnected;
}

@Injectable(as: NetworkInfo)
class NetworkInfoImpl extends NetworkInfo {
  final InternetConnectionChecker _internetConnectionChecker;

  NetworkInfoImpl() : _internetConnectionChecker = InternetConnectionChecker();

  @override
  Future<bool> get isConnected => _internetConnectionChecker.hasConnection;
}
