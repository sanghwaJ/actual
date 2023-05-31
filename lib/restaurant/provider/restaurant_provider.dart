import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/model/pagination_params.dart';
import 'package:actual/restaurant/model/restaurant_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/restaurant_repository.dart';

// family modifier => provider를 생성할 때, 변수 데이터를 받아 provider의 로직을 변경해야 하는 경우 사용
// 반환 값은 RestaurantModel, 입력하는 값은 String
// 이렇게하면 메모리에 있는 RestaurantModel의 값을 가져와 보여주기 때문에 상세 화면 이동 시 로딩이 필요 없음
final restaurantDetailProvider =
    Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);

  if (state is! CursorPagination) {
    return null;
  }

  // firstWhere => 반복한 결과의 첫번째 요소를 반환
  return state.data.firstWhere((element) => element.id == id);
});

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

  Future<void> paginate({
    int fetchCount = 20,
    // true => 추가로 데이터 더 가져옴, false => 새로고침 (현재 상태를 덮어씌움
    bool fetchMore = false,
    // true => 강제로 다시 로딩 (CursorPaginationLoading())
    bool forceRefetch = false,
  }) async {
    try {
      // state 상태 1 => CursorPagination, 정상적으로 데이터가 있는 상태
      // state 상태 2 => CursorPaginationLoading, 데이터가 로딩중인 상태 (현재 캐시 없음)
      // state 상태 3 => CursorPaginationError, 에러가 있는 상태
      // state 상태 4 => CursorPaginationRefetching, 첫 번째 페이지부터 다시 데이터를 가져올 때
      // state 상태 5 => CursorPaginationFetchMore, 추가 데이터를 paginate 하라는 요청을 받았을 때

      /**
       * 바로 반환하는 상황
       */

      // 1) hasMore = false => 이미 로딩이 끝났으며, 데이터를 다 가져와 더 이상 paginate를 할 필요가 없음
      if (state is CursorPagination && !forceRefetch) {
        // 로딩이 끝나고 데이터를 가져오면 CursorPagination에 담겨져 옴
        // But, dart 언어 상으로 CursorPaginationBase를 상속한 CursorPagination임을 모르기 때문에 강제로 casting을 해줌
        final pState = state as CursorPagination; // 100% 일 때만 casting
        if (!pState.meta.hasMore) {
          return; // paginate 실행 X
        }
      }
      // 2) 로딩중 - fetchMore = true
      // 3) 로딩중 - fetchMore = false (새로고침의 의도가 있을 수 있음)
      final isLoading = state is CursorPaginationLoading;
      final isRefetching = state is CursorPaginationRefetching;
      final isFetchingMore = state is CursorPaginationFetchingMore;
      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }

      // paginationParams 생성
      PaginationParams paginationParams = PaginationParams(
        count: fetchCount,
      );

      // fetchMore - 가져온 데이터가 있는데, 추가로 데이터를 더 가져오는 상황
      if (fetchMore) {
        // fetchMore가 true면, 데이터를 무조건 가지고 온 상황이기 때문에 CursorPagination으로 casting
        final pState = state as CursorPagination;

        state = CursorPaginationFetchingMore(
          meta: pState.meta,
          data: pState.data,
        );

        // 데이터의 마지막 id 값을 after에 담음
        paginationParams = paginationParams.copyWith(
          after: pState.data.last.id,
        );
      } else {
        // 데이터를 처음부터 가져오는 상황

        // 만약 데이터가 있는 상황이라면, 기존 데이터를 보존한채로 API 요청(fetch) 진행
        if (state is CursorPagination && !forceRefetch) {
          final pState = state as CursorPagination;

          state = CursorPaginationRefetching(
            meta: pState.meta,
            data: pState.data,
          );
        } else {
          // 데이터를 유지할 필요가 없는 나머지 상황
          state = CursorPaginationLoading();
        }
      }

      // 가장 최근 데이터
      final resp = await repository.paginate(
        paginationParams: paginationParams,
      );

      if (state is CursorPaginationFetchingMore) {
        // 주의! casting은 as!!! (is는 비교하는 값이 서로 같은 인스턴스인지 true or false 값을 주는 것)
        final pState = state as CursorPaginationFetchingMore;

        state = resp.copyWith(
          // 기존 데이터 리스트 + 새 데이터 리스트
          data: [
            ...pState.data,
            ...resp.data,
          ],
        );
      } else {
        state = resp;
      }
    } catch (e) {
      state = CursorPaginationError(message: '데이터를 가져오지 못했습니다.');
    }
  }

  void getDetail({
    required String id,
  }) async {
    // 만약 아직 데이터가 하나도 없는 상태라면(state가 CursorPagination이 아니라면) => 데이터를 가져오는 시도를 함.
    if (state is! CursorPagination) {
      await this.paginate();
    }

    // 데이터를 가져오려는 시도를 했음에도 데이터가 없다면(state가 CursorPagination이 아니라면) => return null
    if (state is! CursorPagination) {
      return;
    }

    final pState = state as CursorPagination;

    final resp = await repository.getRestaurantDetail(id: id);

    // pState에서 id 값에 해당되는 데이터를 restaurantDetailModel로 대체해줘야 함
    state = pState.copyWith(
      data: pState.data.map<RestaurantModel>((e) => e.id == id ? resp : e).toList(),
    );
    /**
     * 위 코드의 동작 과정
     * 1. [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3)]
     * 2. getDetail(2)
     * 3. [RestaurantModel(1), RestaurantModelDetail(2), RestaurantModel(3)]
     */
  }
}
