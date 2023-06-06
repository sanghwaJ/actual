import 'dart:math';

import 'package:actual/product/model/product_model.dart';
import 'package:actual/user/model/basket_item_model.dart';
import 'package:actual/user/model/patch_basket_body.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../repository/user_me_repository.dart';

final basketProvider =
    StateNotifierProvider<BasketProvider, List<BasketItemModel>>(
  (ref) {
    final repository = ref.watch(userMeRepositoryProvider);

    return BasketProvider(
      repository: repository,
    );
  },
);

class BasketProvider extends StateNotifier<List<BasketItemModel>> {
  final UserMeRepository repository;

  BasketProvider({
    required this.repository,
  }) : super([]);

  Future<void> patchBasket() async {
    await repository.patchBasket(
      body: PatchBasketBody(
        basket: state.map(
              (e) => PatchBasketBodyBasket(
            productId: e.product.id,
            count: e.count,
          ),
        ).toList(),
      ),
    );
  }

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

    // Optimistic Response => 응답이 성공할 것이라고 가정하고 상태(캐시)를 먼저 업데이트 하는 것 (App이 더 빠른 것 같은 효과를 줌)
    await patchBasket();
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

    // Optimistic Response => 응답이 성공할 것이라고 가정하고 상태(캐시)를 먼저 업데이트 하는 것 (App이 더 빠른 것 같은 효과를 줌)
    await patchBasket();
  }
}
