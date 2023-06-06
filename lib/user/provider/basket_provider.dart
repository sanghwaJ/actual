import 'dart:math';

import 'package:actual/product/model/product_model.dart';
import 'package:actual/user/model/basket_item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

final basketProvider =
    StateNotifierProvider<BasketProvider, List<BasketItemModel>>(
  (ref) {
    return BasketProvider();
  },
);

class BasketProvider extends StateNotifier<List<BasketItemModel>> {
  BasketProvider() : super([]);

  Future<void> addToBasket({
    required ProductModel product,
  }) async {
    final exists =
        state.firstWhereOrNull((e) => e.product.id == product.id) != null;

    if (exists) {
      // 만약에 상품이 장바구니에 이미 들어있다면, 해당 상품의 count를 +1
      state = state
          .map(
            (e) => e.product.id == product.id
                ? e.copyWith(
                    count: e.count + 1,
                  )
                : e,
          )
          .toList();
    } else {
      // 아직 장바구니에 해당되는 상품이 없다면 장바구니에 상품을 추가
      state = [
        ...state,
        BasketItemModel(
          product: product,
          count: 1,
        ),
      ];
    }
  }

  Future<void> removeFromBasket({
    required ProductModel product,
    bool isDelete = false, // true면 count와는 상관 없이 삭제
  }) async {
    final exists =
        state.firstWhereOrNull((e) => e.product.id == product.id) != null;

    // 장바구니에 상품이 존재하지 않으면, 즉시 함수를 반환하고 아무것도 하지 않음
    if (!exists) {
      return;
    }

    final existingProduct = state.firstWhere((e) => e.product.id == product.id);

    if (existingProduct.count == 1 || isDelete) {
      // 장바구니에 상품이 존재하고, 상품의 카운트가 1이면 삭제
      state = state
          .where(
            // where로 필터링
            (e) => e.product.id != product.id,
          )
          .toList();
    } else {
      // 장바구니에 상품이 존재하고, 상품의 카운트가 1보다 크면 -1
      state = state
          .map(
            (e) => e.product.id == product.id
                ? e.copyWith(
                    count: e.count - 1,
                  )
                : e,
          )
          .toList();
    }
  }
}
