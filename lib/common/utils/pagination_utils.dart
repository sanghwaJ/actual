import 'package:actual/common/provider/pagination_provider.dart';
import 'package:flutter/cupertino.dart';

class PaginationUtils {
  static void paginate({
    required ScrollController controller,
    required PaginationProvider provider,
  }) {
    // 현재 위치가 최대 길이보다 조금 덜 되는 위치까지 왔다면, 새로운 데이터 추가 요청
    // controller.offset => scrollController의 현재 위치
    // controller.position.maxScrollExtent => 최대 스크롤 가능한 크기
    if (controller.offset > controller.position.maxScrollExtent - 300) {
      // PaginationProvider를 사용한다면, 무조건 paginate가 존재
      provider.paginate(
        fetchMore: true,
      );
    }
  }
}
