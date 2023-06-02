import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/model/model_with_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/pagination_params.dart';
import '../repository/base_pagination_repository.dart';

// Generic 안에서는 implement를 사용할 수 없기 때문에, 의미는 implement이지만 extends로 대체함
class PaginationProvider<T extends IModelWithId,
        U extends IBasePaginationRepository<T>>
    extends StateNotifier<CursorPaginationBase> {
  // 일반화한 repository
  // final IBasePaginationRepository repository;
  // 더 발전시켜서, 위에서 선언한 IBasePaginationRepository는 너무 일반화되어 있으니, U는 IBasePaginationRepository와 연관이 있는 repository다! 라고 선언
  final U repository;

  PaginationProvider({
    required this.repository,
  }) : super(CursorPaginationLoading()) {
    // PaginationProvider를 extends하는 모든 provider는 실행 순간, 바로 paginate를 실행함
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
        final pState = state as CursorPagination<T>;

        state = CursorPaginationFetchingMore(
          meta: pState.meta,
          data: pState.data,
        );

        // 데이터의 마지막 id 값을 after에 담음
        paginationParams = paginationParams.copyWith(
          // IModelWithId를 extends한 Generic T를 받아 만든 pState이기 때문에, id를 받지 않으면 Good 에러인 컴파일 에러가 발생!!!
          after: pState.data.last.id,
        );
      } else {
        // 데이터를 처음부터 가져오는 상황

        // 만약 데이터가 있는 상황이라면, 기존 데이터를 보존한채로 API 요청(fetch) 진행
        if (state is CursorPagination && !forceRefetch) {
          final pState = state as CursorPagination<T>;

          state = CursorPaginationRefetching<T>(
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
        final pState = state as CursorPaginationFetchingMore<T>;

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
    } catch (e, stack) {
      print(e);
      print(stack);
      state = CursorPaginationError(message: '데이터를 가져오지 못했습니다.');
    }
  }
}
