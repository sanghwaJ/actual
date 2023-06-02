import '../const/data.dart';

class DataUtils {
  // @JsonKey에 사용할 함수는 무조건 static으로 정의되어야 함
  static String pathToUrl(String value) {
    return 'http://$ip$value';
  }

  // 서버에서 List 값을 보내줄 때, List 안에 타입이 어떤 것이 들어올지 front에서는 알 수 없기 때문에,
  // 일단 아래와 같이 dynamic 타입으로 List를 받아오고, String으로 변환하는 형태로 가야함
  static List<String> listPathsToUrls(List paths) {
    return paths.map((e) => pathToUrl(e)).toList();
  }
}
