// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'local/local_storage.dart' as _i283;
import 'network/api_service.dart' as _i39;
import 'network/dio_factory.dart' as _i732;
import 'network/nnetword_infor.dart' as _i672;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i39.ApiService>(() => _i39.ApiService());
    gh.lazySingleton<_i732.DioFactory>(() => _i732.DioFactory());
    await gh.factoryAsync<_i283.LocalStorage>(
      () {
        final i = _i283.LocalStorageImpl();
        return i.onInitService().then((_) => i);
      },
      preResolve: true,
    );
    gh.factory<_i672.NetworkInfo>(() => _i672.NetworkInfoImpl());
    return this;
  }
}
