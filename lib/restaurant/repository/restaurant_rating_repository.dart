import 'package:actual/common/const/data.dart';
import 'package:actual/common/dio/dio.dart';
import 'package:actual/common/repository/base_pagination_repository.dart';
import 'package:actual/rating/model/rating_model.dart';
import 'package:dio/dio.dart' hide Headers; // 주의!!
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

import '../../common/model/cursor_pagination_model.dart';
import '../../common/model/pagination_params.dart';

part 'restaurant_rating_repository.g.dart';

// family modifier => provider를 생성할 때, 변수 데이터를 받아 provider의 로직을 변경해야 하는 경우 사용
final restaurantRatingRepositoryProvider =
    Provider.family<RestaurantRatingRepository, String>((ref, id) {
  // dio 선언
  final dio = ref.watch(dioProvider);

  return RestaurantRatingRepository(dio,
      baseUrl: 'http://$ip/restaurant/$id/rating');
});

@RestApi()
abstract class RestaurantRatingRepository implements IBasePaginationRepository<RatingModel> {
  factory RestaurantRatingRepository(Dio dio, {String baseUrl}) =
      _RestaurantRatingRepository;

  @GET('/')
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPagination<RatingModel>> paginate({
    // @Queries() => 클래스를 쿼리 파라미터로 변환
    @Queries() PaginationParams? paginationParams = const PaginationParams(),
  });
}
