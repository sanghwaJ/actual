import 'dart:convert';

import 'package:actual/common/dio/dio.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/product/component/product_card.dart';
import 'package:actual/restaurant/component/restaurant_card.dart';
import 'package:actual/restaurant/repository/restaurant_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../common/const/data.dart';
import '../model/restaurant_detail_model.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final String id;

  const RestaurantDetailScreen({
    required this.id,
    Key? key,
  }) : super(key: key);

  Future<RestaurantDetailModel> getRestaurantDetail() async {
    final dio = Dio();

    dio.interceptors.add(
      CustomInterceptor(
        storage: storage,
      ),
    );

    final repository = RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant');

    return repository.getRestaurantDetail(id: id);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      /**
       * 아래 타이틀 수정 필요
       */
      title: '불타는 떡볶이',
      child: FutureBuilder<RestaurantDetailModel>(
        future: getRestaurantDetail(),
        builder: (_, AsyncSnapshot<RestaurantDetailModel> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return CustomScrollView(
            slivers: [
              renderTop(
                model: snapshot.data!,
              ),
              renderLabel(),
              renderProduct(
                products: snapshot.data!.products,
              ),
            ],
          );
        },
      ),
    );
  }

  SliverToBoxAdapter renderTop({
    required RestaurantDetailModel model,
  }) {
    // SliverToBoxAdapter => slivers에 일반 위젯을 넣을 때 사용
    return SliverToBoxAdapter(
      child: RestaurantCard.fromModel(
        model: model,
        isDetail: true,
      ),
    );
  }

  SliverPadding renderLabel() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      sliver: SliverToBoxAdapter(
        child: Text(
          '메뉴',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  SliverPadding renderProduct(
      {required List<RestaurantProductModel> products}) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final model = products[index];

            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ProductCard.fromModel(model: model),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return DefaultLayout(
  //     title: '불타는 떡볶이',
  //     // 서로 다른 리스트가 공존 => customScrollView 사용
  //     child: FutureBuilder<Map<String, dynamic>>(
  //       future: getRestaurantDetail(),
  //       builder: (_, AsyncSnapshot<Map<String, dynamic>> snapshot) {
  //         if (!snapshot.hasData) {
  //           return Center(
  //             child: CircularProgressIndicator(),
  //           );
  //         }
  //
  //         final item = RestaurantDetailModel.fromJson(
  //           json: snapshot.data!,
  //         );
  //
  //         return CustomScrollView(
  //           slivers: [
  //             renderTop(
  //               model: item,
  //             ),
  //             renderLabel(),
  //             renderProduct(
  //               products: item.products,
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }
  //
  // SliverToBoxAdapter renderTop({
  //   required RestaurantDetailModel model,
  // }) {
  //   // SliverToBoxAdapter => slivers에 일반 위젯을 넣을 때 사용
  //   return SliverToBoxAdapter(
  //     child: RestaurantCard.fromModel(
  //       model: model,
  //       isDetail: true,
  //     ),
  //   );
  // }
  //
  // SliverPadding renderLabel() {
  //   return SliverPadding(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: 16.0,
  //     ),
  //     sliver: SliverToBoxAdapter(
  //       child: Text(
  //         '메뉴',
  //         style: TextStyle(
  //           fontSize: 18.0,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // SliverPadding renderProduct(
  //     {required List<RestaurantProductModel> products}) {
  //   return SliverPadding(
  //     padding: EdgeInsets.symmetric(horizontal: 16.0),
  //     sliver: SliverList(
  //       delegate: SliverChildBuilderDelegate(
  //         (context, index) {
  //           final model = products[index];
  //
  //           return Padding(
  //             padding: const EdgeInsets.only(top: 16.0),
  //             child: ProductCard.fromModel(model: model),
  //           );
  //         },
  //         childCount: products.length,
  //       ),
  //     ),
  //   );
  // }
}
