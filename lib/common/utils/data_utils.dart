import '../const/data.dart';

class DataUtils {
  // @JsonKey에 사용할 함수는 무조건 static으로 정의되어야 함
  static pathToUrl(String value) {
    return 'http://$ip$value';
  }
}