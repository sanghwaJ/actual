import 'package:json_annotation/json_annotation.dart';
import '../../restaurant/model/restaurant_model.dart';

part 'cursor_pagination_model.g.dart';

/**
 * CursorPagination 상태 관리
 */
abstract class CursorPaginationBase {}

// 에러
class CursorPaginationError extends CursorPaginationBase {
  final String message;

  CursorPaginationError({
    required this.message,
  });
}

// 로딩중
class CursorPaginationLoading extends CursorPaginationBase {}

// 성공
@JsonSerializable(
  genericArgumentFactories:
      true, // JsonSerializable에서 generic 타입을 사용하는 경우 true 값을 주어야 함
)
// 여러 타입을 받을 수 있게 <T>와 같이 generic 타입으로 지정
class CursorPagination<T> extends CursorPaginationBase {
  final CursorPaginationMeta meta;
  final List<T> data;

  CursorPagination({
    required this.meta,
    required this.data,
  });

  // null 값도 들어올 수 있도록 copyWith를 통해 재정의
  CursorPagination copyWith({
    CursorPaginationMeta? meta,
    List<T>? data,
  }) {
    return CursorPagination(
      meta: meta ?? this.meta,
      data: data ?? this.data,
    );
  }

  // generic으로 받은 타입을 어떻게 json에서 인스턴스로 변환하여 가져올 수 있는지 정의
  factory CursorPagination.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$CursorPaginationFromJson(json, fromJsonT);
}

@JsonSerializable()
class CursorPaginationMeta {
  final int count;
  final bool hasMore;

  CursorPaginationMeta({
    required this.count,
    required this.hasMore,
  });

  CursorPaginationMeta copyWith({
    int? count,
    bool? hasMore,
  }) {
    return CursorPaginationMeta(
      count: count ?? this.count,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  factory CursorPaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$CursorPaginationMetaFromJson(json);
}

// 처음부터 다시 불러오는 중 (리스트 맨 위로 올려서 새로고침)
class CursorPaginationRefetching<T> extends CursorPagination<T> {
  CursorPaginationRefetching({
    required super.meta,
    required super.data,
  });
}

// 추가 데이터 요청중 (리스트 맨 아래로 내려서 요청)
class CursorPaginationFetchingMore<T> extends CursorPagination<T> {
  CursorPaginationFetchingMore({
    required super.meta,
    required super.data,
  });
}
