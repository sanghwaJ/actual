import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Token 저장을 위한 Secure Storage
// 아래의 Provider가 한 번 생기면, 이 때 생긴 FlutterSecureStorage를 계속해서 사용
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => FlutterSecureStorage());
