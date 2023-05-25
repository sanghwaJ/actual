import 'package:actual/common/const/data.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  CustomInterceptor({
    required this.storage,
  });

  /**
   * 요청을 보낼 때
   */
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('[REQ] [${options.method}] ${options.uri}');

    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      // 실제 accessToken으로 대체
      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    if (options.headers['refreshToken'] == 'true') {
      options.headers.remove('refreshToken');

      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      // 실제 토큰으로 대체
      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    return super.onRequest(options, handler); // 이 때 요청이 보내짐
  }

  /**
   * 응답을 받을 때
   */
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}');

    super.onResponse(response, handler);
  }

  /**
   * 에러 발생 시
   */
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // accessToken 기간이 만료되어 401 에러가 났을 때
    print('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    // refreshToken이 없으면 에러를 발생시킴
    if (refreshToken == null) {
      // 에러 발생시킬 때는 handler.reject 사용
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;
    // refreshToken을 통해 accessToken을 받으려다 에러가 났는지 확인
    final isPathRefresh = err.requestOptions.path == '/auth/token';

    // 401 에러가 발생했으며, accessToken이 만료된 경우(refreshToken을 통해 accessToken을 받으려는 것이 아닌 경우)
    if (isStatus401 && !isPathRefresh) {
      /**
       * refreshToken을 통해 accessToken 재발급
       */
      final dio = Dio();

      try {
        final resp = await dio.post(
          'http://$ip/auth/token',
          options: Options(
            headers: {
              'authorization': 'Bearer $refreshToken',
            },
          ),
        );

        final accessToken = resp.data['accessToken'];
        final options = err.requestOptions;

        // accessToken을 재발급하면서 에러가 발생하지 않았다면, header에 accessToken 추가
        options.headers.addAll({
          'authorization': 'Bearer $accessToken',
        });

        // flutter_secure_storage에 새로 발급받은 accessToken 업데이트
        await storage.write(
          key: ACCESS_TOKEN_KEY,
          value: accessToken,
        );

        // 새로 발급받은 accessToken을 통해 다시 요청
        final response = await dio.fetch(options);

        // 에러 없이 요청 완료
        return handler.resolve(response); // 여기서 reponse는 다시 새로 보낸 요청의 응답 값
      } on DioError catch (e) {
        // refreshToken을 통해 accessToken을 재발급 받을 수 없는 상황
        return handler.reject(e);
      }
    }

    return handler.reject(err);
  }
}
