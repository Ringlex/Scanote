import 'package:freezed_annotation/freezed_annotation.dart';

class BoolIntConverter implements JsonConverter<bool, Object?> {
  const BoolIntConverter();

  @override
  bool fromJson(Object? json) => json == 1 || json == true;

  @override
  Object toJson(bool object) => object ? 1 : 0;
}
