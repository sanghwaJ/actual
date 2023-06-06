import 'package:actual/common/utils/data_utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

abstract class UserModelBase {}

// 정상
@JsonSerializable()
class UserModel extends UserModelBase {
  final String id;
  final String username;
  // url 변환을 위해 JsonKey 사용
  @JsonKey(
    fromJson: DataUtils.pathToUrl,
  )
  final String imageUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

// 로딩중
class UserModelLoading extends UserModelBase {}

// 에러
class UserModelError extends UserModelBase {
  final String message;

  UserModelError({
    required this.message,
  });
}
