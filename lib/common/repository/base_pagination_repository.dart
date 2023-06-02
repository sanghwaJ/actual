import 'package:actual/common/model/model_with_id.dart';

import '../model/cursor_pagination_model.dart';
import '../model/pagination_params.dart';

// dart에는 interface가 없지만, abstract class를 통해 구현하여 대체할 수 있음
abstract class IBasePaginationRepository<T extends IModelWithId> {
  Future<CursorPagination<T>> paginate({
    PaginationParams? paginationParams = const PaginationParams(),
  });
}
