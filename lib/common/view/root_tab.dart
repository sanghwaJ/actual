import 'package:actual/common/const/colors.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/restaurant/view/restaurant_screen.dart';
import 'package:flutter/material.dart';

class RootTab extends StatefulWidget {
  const RootTab({Key? key}) : super(key: key);

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  int index = 0;

  // late => 기본으로 controller는 null이지만, 나중에 무조건 controller를 사용할 땐 값이 지정되어 있음을 지정
  late TabController controller;

  // TabController를 사용하려면 initState를 통해 구현
  @override
  void initState() {
    super.initState();

    // vsync에 this를 사용하려면 with SingleTickerProviderStateMixin를 선언해줘야 함
    controller = TabController(length: 4, vsync: this);

    // tabController.addListener => tabController의 값이 변경될 때마다 함수 실행
    controller.addListener(tabListener);
  }

  void tabListener() {
    setState(() {
      index = controller.index;
    });
  }

  // 메모리 관리를 위해 dispose 시 사용한 listener는 삭제
  @override
  void dispose() {
    controller.removeListener(tabListener);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '코팩 딜리버리',
      // TabBarView => Tab을 눌렀을 때 화면 전환하는 위젯
      child: TabBarView(
        // NeverScrollableScrollPhysics => 스크롤 방지
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [
          RestaurantScreen(),
          Center(
            child: Container(
              child: Text('음식'),
            ),
          ),
          Center(
            child: Container(
              child: Text('주문'),
            ),
          ),
          Center(
            child: Container(
              child: Text('프로필'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: PRIMARY_COLOR,
        unselectedItemColor: BODY_TEXT_COLOR,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        // shifting => 선택된 아이콘이 더 크게 표현됨
        // fixed => 크기 고정
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          // 아이콘을 클릭 할 때마다 controller의 index를 변환
          controller.animateTo(index);
        },
        currentIndex: index,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood_outlined),
            label: '음식',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: '주문',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}
