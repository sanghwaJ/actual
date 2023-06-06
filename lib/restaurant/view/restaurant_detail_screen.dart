import 'package:actual/common/const/colors.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/utils/pagination_utils.dart';
import 'package:actual/product/component/product_card.dart';
import 'package:actual/product/model/product_model.dart';
import 'package:actual/rating/component/rating_card.dart';
import 'package:actual/restaurant/component/restaurant_card.dart';
import 'package:actual/restaurant/provider/restaurant_provider.dart';
import 'package:actual/restaurant/provider/restaurant_rating_provider.dart';
import 'package:actual/restaurant/view/basket_screen.dart';
import 'package:actual/user/provider/basket_provider.dart';
import 'package:flutter/material.dart' hide Badge; // 주의
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletons/skeletons.dart';
import 'package:badges/badges.dart';

import '../../rating/model/rating_model.dart';
import '../model/restaurant_detail_model.dart';
import '../model/restaurant_model.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'restaurantDetail';

  final String id;

  const RestaurantDetailScreen({
    required this.id,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState
    extends ConsumerState<RestaurantDetailScreen> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    // getDetail 요청이 들어가 전체적으로 새로 렌더링을 하기는 하지만, 그 전에는 메모리에 있는 이미지를 보여주어 App이 더 빠른 것처럼 보임
    ref.read(restaurantProvider.notifier).getDetail(id: widget.id);

    controller.addListener(listener);
  }

  void listener() {
    PaginationUtils.paginate(
      controller: controller,
      provider: ref.read(restaurantRatingProvider(widget.id).notifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restaurantDetailProvider(widget.id));
    final ratingsState = ref.watch(restaurantRatingProvider(widget.id));
    final basket = ref.watch(basketProvider);

    if (state == null) {
      return DefaultLayout(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DefaultLayout(
      title: state.name,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(BasketScreen.routeName);
        },
        backgroundColor: PRIMARY_COLOR,
        child: Badge(
          showBadge: basket.isNotEmpty,
          badgeContent: Text(
            basket
                .fold<int>(
                  0,
                  (previous, next) => previous + next.count,
                )
                .toString(),
            style: TextStyle(
              color: PRIMARY_COLOR,
              fontSize: 10.0,
            ),
          ),
          badgeStyle: BadgeStyle(
            badgeColor: Colors.white,
          ),
          child: Icon(Icons.shopping_basket_outlined),
        ),
      ),
      child: CustomScrollView(
        controller: controller,
        slivers: [
          renderTop(
            model: state,
          ),
          // 아래와 같이 if문을 통해 기존에 있는 데이터는 그대로 남겨서 보여주고, 나머지 데이터를 로딩해서 보여줌
          if (state is! RestaurantDetailModel) renderLoading(),
          if (state is RestaurantDetailModel) renderLabel(),
          if (state is RestaurantDetailModel)
            renderProduct(
              restaurant: state,
              products: state.products,
            ),
          if (ratingsState is CursorPagination<RatingModel>)
            renderRatings(
              models: ratingsState.data,
            ),
        ],
      ),
    );
  }

  // skeletons 적용
  SliverPadding renderLoading() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: SkeletonParagraph(
                style: SkeletonParagraphStyle(
                  lines: 5,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter renderTop({
    required RestaurantModel model,
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

  SliverPadding renderProduct({
    required RestaurantModel restaurant,
    required List<RestaurantProductModel> products,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final model = products[index];

            return InkWell(
              // InkWell 위젯을 사용하면, 눌렀을 때 실행될 action을 onTap에 정의할 수 있음
              // GestureDetector는 누르면 누르는 animation이 없지만, InkWell은 animation이 있음
              onTap: () {
                ref.read(basketProvider.notifier).addToBasket(
                      product: ProductModel(
                        id: model.id,
                        name: model.name,
                        detail: model.detail,
                        imgUrl: model.imgUrl,
                        price: model.price,
                        restaurant: restaurant,
                      ),
                    );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ProductCard.fromRestaurantProductModel(model: model),
              ),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  SliverPadding renderRatings({
    required List<RatingModel> models,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: RatingCard.fromModel(
              model: models[index],
            ),
          ),
          childCount: models.length,
        ),
      ),
    );
  }
}
