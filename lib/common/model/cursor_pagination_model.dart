import 'package:json_annotation/json_annotation.dart';
import '../../restaurant/model/restaurant_model.dart';

part 'cursor_pagination_model.g.dart';

@JsonSerializable(
  genericArgumentFactories: true, // JsonSerializable에서 generic 타입을 사용하는 경우 true 값을 주어야 함
)
class CursorPagination<T> { // 여러 타입을 받을 수 있게 <T>와 같이 generic 타입으로 지정
  final CursorPaginationMeta meta;
  final List<T> data;

  CursorPagination({
    required this.meta,
    required this.data,
  });

  // generic으로 받은 타입을 어떻게 json에서 인스턴스로 변환하여 가져올 수 있는지 정의
  factory CursorPagination.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT)
  => _$CursorPaginationFromJson(json, fromJsonT);
}

@JsonSerializable()
class CursorPaginationMeta {
  final int count;
  final bool hasMore;

  CursorPaginationMeta({
    required this.count,
    required this.hasMore,
  });

  factory CursorPaginationMeta.fromJson(Map<String, dynamic> json)
  => _$CursorPaginationMetaFromJson(json);

}
