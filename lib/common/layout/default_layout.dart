import 'package:flutter/material.dart';

/**
 * 공통 Layout
 * 모든 페이지에 공통적으로 적용할 요소(디자인, 기능 등)가 있다면, DefaultLayout으로 감싸고 각 screen들을 구현하는 것이 효과적
 */
class DefaultLayout extends StatelessWidget {
  final Color? backgroundColor;
  final Widget child;

  const DefaultLayout({
    this.backgroundColor,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      body: child,
    );
  }
}
