import 'package:actual/common/model/model_with_id.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../common/const/data.dart';
import '../../common/utils/data_utils.dart';

// Code Generate
part 'restaurant_model.g.dart';

enum RestaurantPriceRange {
  expensive,
  medium,
  cheap,
}

@JsonSerializable()
class RestaurantModel implements IModelWithId {
  final String id;
  final String name;
  // 생성된 .g.dart 파일은 수정하면 안되기 때문에 커스텀마이징은 아래와 같이 해야 함
  @JsonKey(
    // fromJson : json -> 클래스 인스턴스
    fromJson: DataUtils.pathToUrl,
    // toJson : 클래스 인스턴스 -> json
  )
  final String thumbUrl;
  final List<String> tags;
  final RestaurantPriceRange priceRange;
  final double ratings;
  final int ratingsCount;
  final int deliveryTime;
  final int deliveryFee;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.thumbUrl,
    required this.tags,
    required this.priceRange,
    required this.ratings,
    required this.ratingsCount,
    required this.deliveryTime,
    required this.deliveryFee,
  });

  /**
   * factory constructor
   * Model 클래스를 인스턴스로 변환하여 사용
   */
  /**
   * Code Generate를 통해 생성된 restaurant_model.g.dart로 대체
   */
  // json -> 인스턴스
  factory RestaurantModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantModelFromJson(json);
  // 클래스 인스턴스 -> json
  Map<String, dynamic> toJson() => _$RestaurantModelToJson(this); // this는 현재 클래스의 인스턴스를 의미

  // factory RestaurantModel.fromJson({
  //   // json 값을 받아올 땐, 항상 Map<String, dynamic>으로 표현해 줘야함
  //   required Map<String, dynamic> json,
  // }) {
  //   return RestaurantModel(
  //     id: json['id'],
  //     name: json['name'],
  //     thumbUrl: 'http://$ip${json['thumbUrl']}',
  //     // List<dynamic> => List<String> 변환
  //     tags: List<String>.from(json['tags']),
  //     priceRange: RestaurantPriceRange.values
  //         .firstWhere((e) => e.name == json['priceRange']),
  //     ratings: json['ratings'],
  //     ratingsCount: json['ratingsCount'],
  //     deliveryTime: json['deliveryTime'],
  //     deliveryFee: json['deliveryFee'],
  //   );
  // }
}
