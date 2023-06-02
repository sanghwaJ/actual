import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/model/pagination_params.dart';
import 'package:actual/common/provider/pagination_provider.dart';
import 'package:actual/restaurant/model/restaurant_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/restaurant_repository.dart';
import 'package:collection/collection.dart';

// family modifier => provider를 생성할 때, 변수 데이터를 받아 provider의 로직을 변경해야 하는 경우 사용
// 반환 값은 RestaurantModel, 입력하는 값은 String
// 이렇게하면 메모리에 있는 RestaurantModel의 값을 가져와 보여주기 때문에 상세 화면 이동 시 로딩이 필요 없음
final restaurantDetailProvider =
    Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);

  if (state is! CursorPagination) {
    return null;
  }

  // firstWhere => 반복한 결과의 첫번째 요소를 반환 (만약 해당 요소가 없다면 에러를 발생시킴)
  // firstWhereOrNull => 반복한 결과의 첫번째 요소를 반환 (만약 해당 요소가 없다면 그냥 Null 반환)
  return state.data.firstWhereOrNull((element) => element.id == id);
});

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>((ref) {
  final repository = ref.watch(restaurantRepositoryProvider);
  final notifier = RestaurantStateNotifier(repository: repository);

  return notifier;
});

// PaginationProvider를 상속하면 PaginationProvider는 StateNotifier를 extends하기 때문에 StateNotifier를 무리없이 사용이 가능함!
// 또한, PaginationProvider 안에 paginate 함수가 정의되어 있기 때문에, PaginationProvider를 extends하면 바로 paginate가 가능함!
class RestaurantStateNotifier
    extends PaginationProvider<RestaurantModel, RestaurantRepository> {
  RestaurantStateNotifier({
    required super.repository,
  });

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

    if (pState.data.where((e) => e.id == id).isEmpty) {
      /**
       * id를 통해 요청한 데이터가 캐시에 존재하지 않는다면
       * 1. [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3)]
       * 2. getDetail(10) => 데이터 없다면 에러 발생!
       * 3. 따라서, 이를 방지하기 위해 데이터가 없을 땐 캐시에 끝에다가 데이터를 그냥 추가해줌
       *    => [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3), RestaurantModelDetail(10)]
       */
      state = pState.copyWith(
        data: <RestaurantModel>[
          ...pState.data,
          resp,
        ],
      );
    } else {
      /**
       * id를 통해 요청한 데이터가 캐시에 존재한다면
       * 1. [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3)]
       * 2. getDetail(2)
       * 3. [RestaurantModel(1), RestaurantModelDetail(2), RestaurantModel(3)]
       */
      // pState에서 id 값에 해당되는 데이터를 restaurantDetailModel로 대체해줘야 함
      state = pState.copyWith(
        data: pState.data
            .map<RestaurantModel>((e) => e.id == id ? resp : e)
            .toList(),
      );
    }
  }
}
