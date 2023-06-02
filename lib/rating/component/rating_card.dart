import 'package:actual/common/const/colors.dart';
import 'package:actual/rating/model/rating_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class RatingCard extends StatelessWidget {
  // Image => NetworkImage, AssetImage
  // CircleAvatar 위젯에 포함
  final ImageProvider avatarImage;
  // 리스트로 이미지 보여주는 위젯에 포함
  final List<Image> images;
  // 별점
  final int rating;
  // 이메일
  final String email;
  // 리뷰 내용
  final String content;

  const RatingCard({
    required this.avatarImage,
    required this.images,
    required this.rating,
    required this.email,
    required this.content,
    Key? key,
  }) : super(key: key);

  factory RatingCard.fromModel({
    required RatingModel model,
  }) {
    return RatingCard(
      avatarImage: NetworkImage(
        model.user.imageUrl,
      ),
      images: model.imgUrls.map((e) => Image.network(e)).toList(),
      rating: model.rating,
      email: model.user.username,
      content: model.content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(
          avatarImage: avatarImage,
          email: email,
          rating: rating,
        ),
        const SizedBox(
          height: 8.0,
        ),
        _Body(
          content: content,
        ),
        // 좌우 스크롤을 하는 ListView인 경우, height를 지정해줘야 함
        if (images.length > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 100,
              child: _Images(
                images: images,
              ),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final ImageProvider avatarImage;
  final int rating;
  final String email;

  const _Header({
    required this.avatarImage,
    required this.rating,
    required this.email,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12.0,
          backgroundImage: avatarImage,
        ),
        const SizedBox(
          width: 8.0,
        ),
        Expanded(
          child: Text(
            email,
            // Text가 줄에서 초과되면 .. 으로 줄여서 보여줌
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...List.generate(
          5,
          (index) => Icon(
            index < rating ? Icons.star : Icons.star_border_outlined,
            color: PRIMARY_COLOR,
          ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  final String content;

  const _Body({
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          // Flexible로 Text를 감싸면 글자가 화면을 넘어가는 경우, 다음 줄로 보여줌
          Flexible(
            child: Text(
              content,
              style: TextStyle(
                color: BODY_TEXT_COLOR,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Images extends StatelessWidget {
  final List<Image> images;

  const _Images({
    required this.images,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      // 좌우로만 스크롤이 가능하도록 지정
      scrollDirection: Axis.horizontal,
      // 기본적으로 image를 map으로 받을 때, index를 받는 것이 불가함
      // 하지만, import 'package:collection/collection.dart';를 하고, mapIndexed를 사용하면 index를 받을 수 있음
      children: images
          .mapIndexed(
            (index, e) => Padding(
              padding:
                  EdgeInsets.only(right: index == images.length - 1 ? 0 : 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: e,
              ),
            ),
          )
          .toList(),
    );
  }
}
