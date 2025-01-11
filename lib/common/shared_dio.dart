import 'package:dio/dio.dart';

final sharedDio = Dio();

extension ResponseEx on Response<dynamic> {
  bool get isSuccess => statusCode == null ? false : (statusCode! >= 200 && statusCode! <= 300);
}