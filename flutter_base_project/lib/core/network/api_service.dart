import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';

import '../constans.dart';
import 'dio_factory.dart';

@singleton
class ApiService {
  final Dio _dio;
  final CacheManager _cacheManager = CustomCacheManager.instance;

  ApiService() : _dio = DioFactory().dio;

  // Future<Response> get(
  //     {required String endPoint, dynamic data, dynamic params}) async {
  //   var response = await _dio.get('${Constants.BASE_URL}$endPoint',
  //       data: data, queryParameters: params);
  //   return response;
  // }

  Future<Response> get({
    required String endPoint,
    dynamic data,
    dynamic params,
    Duration cacheDuration =
        const Duration(seconds: 60), // Custom cache duration
  }) async {
    try {
      String url = '${Constants.BASE_URL}$endPoint';

      // Create a unique cache key based on URL and parameters
      String cacheKey = _generateCacheKey(url, params);

      // Check if cached data exists
      var fileInfo = await _cacheManager.getFileFromCache(cacheKey);

      if (fileInfo != null && _isCacheValid(fileInfo, cacheDuration)) {
        // Use cached data
        String cachedData = await fileInfo.file.readAsString();

        // Ensure that the cached data is a Map<String, dynamic>
        Map<String, dynamic> decodedJson =
            json.decode(cachedData) as Map<String, dynamic>;

        return Response(
          requestOptions: RequestOptions(path: url),
          data: decodedJson,
          statusCode: 200,
        );
      }

      // No valid cache found, make network request
      var response = await _dio.get('${Constants.BASE_URL}$endPoint',
          data: data, queryParameters: params);

      // Cache the response data
      await _cacheManager.putFile(
        cacheKey,
        utf8.encode(json.encode(response.data)),
        fileExtension: 'json',
      );

      return response;
    } on DioException catch (e) {
      print("DioError: ${e.toString()}");
      rethrow;
    }
  }

  Future<Response> post(
      {required String endPoint, dynamic data, dynamic params}) async {
    var response = await _dio.post('${Constants.BASE_URL}$endPoint',
        data: data, queryParameters: params);
    return response;
  }

  Future<Response> put({required String endPoint}) async {
    var response = await _dio.put('${Constants.BASE_URL}$endPoint');
    return response;
  }

  Future<Response> delete({required String endPoint}) async {
    var response = await _dio.delete('${Constants.BASE_URL}$endPoint');
    return response;
  }

  // Helper method to generate a unique cache key based on URL and parameters
  String _generateCacheKey(String url, Map<dynamic, dynamic>? params) {
    String paramsString = params != null ? json.encode(params) : '';
    return url + paramsString;
  }

  // Helper method to check cache validity based on the provided duration
  bool _isCacheValid(FileInfo fileInfo, Duration cacheDuration) {
    DateTime now = DateTime.now();
    return now.difference(fileInfo.validTill).inSeconds <
        cacheDuration.inSeconds;
  }
}

class CustomCacheManager {
  static const key = 'customCacheKey';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 2048,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileSystem: IOFileSystem(key),
      fileService: HttpFileService(),
    ),
  );
}
