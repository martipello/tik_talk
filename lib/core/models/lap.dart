import 'package:freezed_annotation/freezed_annotation.dart';

part 'lap.freezed.dart';

@freezed
class Lap with _$Lap {
  const factory Lap({required Duration elapsed, String? label}) = _Lap;
}
