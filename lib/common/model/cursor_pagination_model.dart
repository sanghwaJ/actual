import 'package:json_annotation/json_annotation.dart';

part 'cursor_pagination_model.g.dart';

// @JsonSerializable()
// class CursorPaginationModel {
//   final CursorPaginationMeta meta;
//   final List<RestaurantModel> data;
//
//   CursorPaginationModel({
//     required this.meta,
//     required this.data,
// });
//   factory CursorPaginationModel.fromJson(Map<Stringm dynamic> json)
//   => _$CursorPaginationModelFromJson(json);
//
// }

@JsonSerializable()
class CursorPaginationMeta {
  final int count;
  final bool hasMore;

  CursorPaginationMeta({
    required this.count,
    required this.hasMore,
  });
  
  // factory CursorPaginationMeta.fromJson(Map<Stringm dynamic> json)
  // => _$CursorPaginationMetaFromJson(json);
}
