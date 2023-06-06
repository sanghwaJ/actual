import 'package:actual/common/view/root_tab.dart';
import 'package:actual/common/view/splash_screen.dart';
import 'package:actual/order/view/order_done_screen.dart';
import 'package:actual/restaurant/view/basket_screen.dart';
import 'package:actual/restaurant/view/restaurant_detail_screen.dart';
import 'package:actual/user/provider/user_me_provider.dart';
import 'package:actual/user/view/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../model/user_model.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref: ref);
});

class AuthProvider extends ChangeNotifier {
  final Ref ref;

  AuthProvider({
    required this.ref,
  }) {
    ref.listen<UserModelBase?>(userMeProvider, (previous, next) {
      // userMeProvider에 변경 사항이 생겼을 때, 실행
      if (previous != next) {
        notifyListeners();
      }
    });
  }

  /**
   * router.dart로 이동
   */
  List<GoRoute> get routes => [
        GoRoute(
          path: '/',
          name: RootTab.routeName,
          builder: (_, __) => RootTab(),
          routes: [
            GoRoute(
              path: 'restaurant/:rid',
              name: RestaurantDetailScreen.routeName,
              builder: (_, state) => RestaurantDetailScreen(
                // path의 :rid 값
                id: state.params['rid']!,
                // goRouter v7
                // id: state.pathParameters['rid']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/basket',
          name: BasketScreen.routeName,
          builder: (_, __) => BasketScreen(),
        ),
        GoRoute(
          path: '/order_done',
          name: OrderDoneScreen.routeName,
          builder: (_, __) => OrderDoneScreen(),
        ),
        GoRoute(
          path: '/splash',
          name: SplashScreen.routeName,
          builder: (_, __) => SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: LoginScreen.routeName,
          builder: (_, __) => LoginScreen(),
        ),
      ];

  // dio에서 사용하기 위해 선언된 logout
  void logout() {
    // 이 함수가 실행되는 순간에만 userMeProvider의 logout을 불러옴
    ref.read(userMeProvider.notifier).logout();
  }

  /**
   * redirect
   */
  // v7에는 BuildContext context 파라미터 추가
  String? redirectLogic(GoRouterState state) {
    final UserModelBase? user = ref.read(userMeProvider);
    final loginIn = state.location == '/login';

    // CASE 1) 유저 정보가 없는데, 로그인 중이면 그대로 로그인 화면에 유지하고, 만약 로그인 중이 아니라면 로그인 화면으로 이동
    if (user == null) {
      return loginIn ? null : '/login';
    }

    // CASE 2) 유저 정보가 있는데(user != null), 로그인 중이거나 현재 위치가 SplashScreen이면, 홈으로 이동
    // SplashScreen이 필요한 이유 => App을 처음 시작했을 때, 토큰이 존재하는지 확인하고 로그인으로 보낼지, 홈으로 보낼지 확인하는 과정이 필요하기 때문
    if (user is UserModel) {
      return loginIn || state.location == '/splash' ? '/' : null;
    }

    // CASE 3) 에러 상황인 경우
    if (user is UserModelError) {
      return !loginIn ? '/login' : null;
    }

    // 나머지 경우엔 현재 화면 유지
    return null;
  }
}
