import 'package:flutter/material.dart';

import '../const/colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final bool autoFocus;
  final ValueChanged<String>? onChanged;

  const CustomTextFormField({
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.autoFocus = false,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // OutlineInputBorder => input 테두리에 줄
    // UnderlineInputBorder(default) => input에 밑줄
    final baseBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: INPUT_BORDER_COLOR,
        width: 1.0,
      ),
    );

    return TextFormField(
      cursorColor: PRIMARY_COLOR,
      // 비밀번호 입력할 때 사용 (asterisk 처리)
      obscureText: obscureText,
      // input 자동 포커스
      autofocus: autoFocus,
      // 값이 바뀔 때마다 콜백
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(20),
        hintText: hintText,
        errorText: errorText,
        hintStyle: TextStyle(
          color: BODY_TEXT_COLOR,
          fontSize: 14.0,
        ),
        // input 배경 컬러
        fillColor: INPUT_BG_COLOR,
        // true => 배경색 있음 / false => 배경색 없음
        filled: true,
        // 모든 input의 기본 스타일 세팅
        border: baseBorder,
        // 활성화되어 있지만 focus가 되어 있지 않은 border 스타일 셋팅
        enabledBorder: baseBorder,
        // 선택된 input
        focusedBorder: baseBorder.copyWith(
          borderSide: baseBorder.borderSide.copyWith(
            color: PRIMARY_COLOR,
          ),
        ),
      ),
    );
  }
}
