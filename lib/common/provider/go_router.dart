import 'package:actual/user/provider/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>(
  (ref) {
    // watch - 값이 변경될때마다 다시 빌드
    // read - 한번만 읽고 값이 변경돼도 다시 빌드하지 않음
    final provider = ref.read(authProvider);

    return GoRouter(
      routes: provider.routes,
      initialLocation: '/splash',
      refreshListenable: provider,
      redirect: provider.redirectLogic,
    );
  },
);

// final routerProvider = Provider<GoRouter>(
//   (ref) {
//     // read => 한 번만 읽고, 값이 변경되도 다시 빌드하지 않음
//     // watch => 값이 변경될 때마다 빌드
//     final provider = ref.read(authProvider);
//
//     return GoRouter(
//       redirect: (context, state) {
//         final UserModelBase? user = ref.read(userMeProvider);
//         final loginIn = state.location == '/login';
//
//         // CASE 1) 유저 정보가 없는데, 로그인 중이면 그대로 로그인 화면에 유지하고, 만약 로그인 중이 아니라면 로그인 화면으로 이동
//         if (user == null) {
//           return loginIn ? null : '/login';
//         }
//
//         // CASE 2) 유저 정보가 있는데(user != null), 로그인 중이거나 현재 위치가 SplashScreen이면, 홈으로 이동
//         // SplashScreen이 필요한 이유 => App을 처음 시작했을 때, 토큰이 존재하는지 확인하고 로그인으로 보낼지, 홈으로 보낼지 확인하는 과정이 필요하기 때문
//         if (user is UserModel) {
//           return loginIn || state.location == '/splash' ? '/' : null;
//         }
//
//         // CASE 3) 에러 상황인 경우
//         if (user is UserModelError) {
//           return !loginIn ? '/login' : null;
//         }
//
//         // 나머지 경우엔 현재 화면 유지
//         return null;
//       },
//       initialLocation: '/splash',
//       refreshListenable: provider,
//       routes: [
//         GoRoute(
//           path: '/',
//           name: RootTab.routeName,
//           builder: (_, __) => RootTab(),
//           routes: [
//             GoRoute(
//               path: 'restaurant/:rid',
//               builder: (_, state) => RestaurantDetailScreen(
//                 // path의 :rid 값
//                 id: state.pathParameters['rid']!,
//               ),
//             ),
//           ],
//         ),
//         GoRoute(
//           path: '/splash',
//           name: SplashScreen.routeName,
//           builder: (_, __) => SplashScreen(),
//         ),
//         GoRoute(
//           path: '/login',
//           name: LoginScreen.routeName,
//           builder: (_, __) => LoginScreen(),
//         ),
//       ],
//       debugLogDiagnostics: true,
//     );
//   },
// );
