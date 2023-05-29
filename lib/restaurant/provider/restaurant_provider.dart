import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/restaurant/model/restaurant_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/restaurant_repository.dart';

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>((ref) {
  final repository = ref.watch(restaurantRepositoryProvider);
  final notifier = RestaurantStateNotifier(repository: repository);

  return notifier;
});

class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {
  final RestaurantRepository repository;

  RestaurantStateNotifier({required this.repository})
      : super(
          CursorPaginationLoading(),
        ) {
    // RestaurantStateNotifier가 생성되는 순간, 바로 paginate 실행
    paginate();
  }

  paginate({
    int fetchCount = 20,
    // true => 추가로 데이터 더 가져옴, false => 새로고침 (현재 상태를 덮어씌움
    bool fetchMore = false,
    // true => 강제로 다시 로딩 (CursorPaginationLoading())
    bool forceRefetch = false,
  }) async {
    // state 상태 1 => CursorPagination, 정상적으로 데이터가 있는 상태
    // state 상태 2 => CursorPaginationLoading, 데이터가 로딩중인 상태 (현재 캐시 없음)
    // state 상태 3 => CursorPaginationError, 에러가 있는 상태
    // state 상태 4 => CursorPaginationRefetching, 첫 번째 페이지부터 다시 데이터를 가져올 때
    // state 상태 5 => CursorPaginationFetchMore, 추가 데이터를 paginate 하라는 요청을 받았을 때

  }
}
