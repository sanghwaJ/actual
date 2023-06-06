import 'dart:convert';
import 'dart:io';

import 'package:actual/common/const/colors.dart';
import 'package:actual/common/const/data.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/common/secure_storage/secure_storage.dart';
import 'package:actual/common/view/root_tab.dart';
import 'package:actual/user/model/user_model.dart';
import 'package:actual/user/provider/user_me_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../common/component/custom_text_form_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static String get routeName => 'login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userMeProvider);

    return DefaultLayout(
      // 키보드 오픈 시 화면이 잘려 에러가 발생하는 상황을 방지하기위해, 화면 전체를 스크롤이 가능한 SingleChildScrollView로 감싸줌
      child: SingleChildScrollView(
        // 화면을 드래그 한 순간, 키보드가 사라짐
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Title(),
                const SizedBox(
                  height: 16.0,
                ),
                _SubTitle(),
                Image.asset(
                  'asset/img/misc/logo.png',
                  width: MediaQuery.of(context).size.width / 3 * 2,
                ),
                CustomTextFormField(
                  hintText: '이메일을 입력해주세요.',
                  onChanged: (String value) {
                    username = value;
                  },
                ),
                const SizedBox(
                  height: 16.0,
                ),
                CustomTextFormField(
                  hintText: '비밀번호를 입력해주세요.',
                  onChanged: (String value) {
                    password = value;
                  },
                  obscureText: true,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                  onPressed: state is UserModelLoading
                      ? null // onPressed가 null이면 버튼을 누를 수 없음 = 로딩 중에는 버튼을 누를 수 없음
                      : () async {
                          ref.read(userMeProvider.notifier).login(
                                username: username,
                                password: password,
                              );
                          // ID:PW
                          // final rawString = '$username:$password';
                          //
                          // // String을 Base64로 인코딩
                          // Codec<String, String> stringToBase64 = utf8.fuse(base64);
                          // String token = stringToBase64.encode(rawString);
                          //
                          // final resp = await dio.post(
                          //   'http://$ip/auth/login',
                          //   options: Options(
                          //     headers: {
                          //       'authorization': 'Basic $token',
                          //     },
                          //   ),
                          // );
                          //
                          // final refreshToken = resp.data['refreshToken'];
                          // final accessToken = resp.data['accessToken'];
                          //
                          // // 함수 부분이 아니기 때문에 watch가 아닌 read 사용!
                          // final storage = ref.read(secureStorageProvider);
                          //
                          // storage.write(key: REFRESH_TOKEN_KEY, value: refreshToken);
                          // storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);
                          //
                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (_) => RootTab(),
                          //   ),
                          // );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_COLOR,
                  ),
                  child: Text(
                    '로그인',
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextButton(
                  onPressed: () async {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    '회원가입',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '환영합니다!',
      style: TextStyle(
        fontSize: 34.0,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '이메일과 비밀번호를 입력해서 로그인 해주세요!\n오늘도 성공적인 주문이 되길 :)',
      style: TextStyle(
        fontSize: 16.0,
        color: BODY_TEXT_COLOR,
      ),
    );
  }
}
