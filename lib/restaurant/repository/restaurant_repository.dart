import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/restaurant/model/restaurant_detail_model.dart';
import 'package:actual/restaurant/model/restaurant_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

part 'restaurant_repository.g.dart';

@RestApi()
abstract class RestaurantRepository { // abstract 선언 필수!
  // baseUrl : http://$ip/restaurant
  factory RestaurantRepository(Dio dio, {String baseUrl}) =
      _RestaurantRepository;

  @GET('/')
  @Headers({
    'accessToken' : 'true',
  })
  Future<CursorPagination<RestaurantModel>> paginate();

  @GET('/{id}')
  @Headers({
    'accessToken' : 'true',
  })
  // 외부에서 받는 값이기 떄문에 Future 선언
  Future<RestaurantDetailModel> getRestaurantDetail({
    @Path() required String id, // 변수 이름과 파라미터 이름이 다르면 @Path('rid')로 선언해야 함
  });
}
