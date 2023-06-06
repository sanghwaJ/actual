import 'package:actual/user/model/user_model.dart';
import 'package:actual/user/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../common/const/data.dart';
import '../../common/secure_storage/secure_storage.dart';
import '../repository/user_me_repository.dart';

final userMeProvider = StateNotifierProvider<UserMeStateNotifier, UserModelBase?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userMeRepository = ref.watch(userMeRepositoryProvider);
  final storage = ref.watch(secureStorageProvider);

  return UserMeStateNotifier(
    authRepository: authRepository,
    userMeRepository: userMeRepository,
    storage: storage,
  );
});

class UserMeStateNotifier extends StateNotifier<UserModelBase?> {
  final AuthRepository authRepository;
  final UserMeRepository userMeRepository;
  final FlutterSecureStorage storage;

  UserMeStateNotifier({
    required this.authRepository,
    required this.userMeRepository,
    required this.storage,
  }) : super(UserModelLoading()) {
    // UserMeStateNotifier 클래스가 인스턴스화 되면, 일단 가지고 있는 토큰으로 정보를 가져옴
    getMe();
  }

  Future<void> getMe() async {
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    if (refreshToken == null || accessToken == null) {
      // refreshToken과 accessToken 모두 null이면, 로그오프 상태이기 때문에 state를 null로 지정
      state = null;
      return;
    }

    final resp = await userMeRepository.getMe();

    state = resp;
  }

  Future<UserModelBase> login({
    required String username,
    required String password,
  }) async {
    try {
      // 일단 로그인 시도를 하면, 로딩 상태로 변경
      state = UserModelLoading();

      final resp = await authRepository.login(
        username: username,
        password: password,
      );

      // 로그인을 하면, 토큰을 발급하고, FlutterSecureStorage에 저장
      await storage.write(key: REFRESH_TOKEN_KEY, value: resp.refreshToken);
      await storage.write(key: ACCESS_TOKEN_KEY, value: resp.accessToken);

      // 발급된 토큰으로 해당 유저 정보를 가져옴 (유효한 토큰인지 판별하기 위해)
      final userResp = await userMeRepository.getMe();

      state = userResp;

      return userResp;
    } catch (e) {
      // 사실 에러 메시지는 아이디가 틀렸다던지, 비밀번호가 틀렸다던지 상세히 안내해주는 것이 좋음
      state = UserModelError(message: '로그인에 실패했습니다.');

      // UserModelError는 UserModelBase를 상속받기 때문에, 리턴이 가능
      return Future.value(state);
    }
  }

  Future<void> logout() async {
    // state가 null이 되면 바로 로그인 페이지로 이동하도록 설계되었기 때문에, 빠른 응답을 위해 제일 먼저 state를 null로 처리
    state = null;

    // accessToken과 refreshToken 동시 삭제
    await Future.wait({
      storage.delete(key: REFRESH_TOKEN_KEY),
      storage.delete(key: ACCESS_TOKEN_KEY),
    });

    // accessToken과 refreshToken 순서대로 삭제
    // await storage.delete(key: REFRESH_TOKEN_KEY);
    // await storage.delete(key: ACCESS_TOKEN_KEY);
  }
}
