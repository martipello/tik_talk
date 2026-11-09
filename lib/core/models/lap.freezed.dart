// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lap.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Lap {
  Duration get elapsed => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;

  /// Create a copy of Lap
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LapCopyWith<Lap> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LapCopyWith<$Res> {
  factory $LapCopyWith(Lap value, $Res Function(Lap) then) =
      _$LapCopyWithImpl<$Res, Lap>;
  @useResult
  $Res call({Duration elapsed, String? label});
}

/// @nodoc
class _$LapCopyWithImpl<$Res, $Val extends Lap> implements $LapCopyWith<$Res> {
  _$LapCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Lap
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? elapsed = null, Object? label = freezed}) {
    return _then(
      _value.copyWith(
            elapsed: null == elapsed
                ? _value.elapsed
                : elapsed // ignore: cast_nullable_to_non_nullable
                      as Duration,
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LapImplCopyWith<$Res> implements $LapCopyWith<$Res> {
  factory _$$LapImplCopyWith(_$LapImpl value, $Res Function(_$LapImpl) then) =
      __$$LapImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Duration elapsed, String? label});
}

/// @nodoc
class __$$LapImplCopyWithImpl<$Res> extends _$LapCopyWithImpl<$Res, _$LapImpl>
    implements _$$LapImplCopyWith<$Res> {
  __$$LapImplCopyWithImpl(_$LapImpl _value, $Res Function(_$LapImpl) _then)
    : super(_value, _then);

  /// Create a copy of Lap
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? elapsed = null, Object? label = freezed}) {
    return _then(
      _$LapImpl(
        elapsed: null == elapsed
            ? _value.elapsed
            : elapsed // ignore: cast_nullable_to_non_nullable
                  as Duration,
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$LapImpl implements _Lap {
  const _$LapImpl({required this.elapsed, this.label});

  @override
  final Duration elapsed;
  @override
  final String? label;

  @override
  String toString() {
    return 'Lap(elapsed: $elapsed, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LapImpl &&
            (identical(other.elapsed, elapsed) || other.elapsed == elapsed) &&
            (identical(other.label, label) || other.label == label));
  }

  @override
  int get hashCode => Object.hash(runtimeType, elapsed, label);

  /// Create a copy of Lap
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LapImplCopyWith<_$LapImpl> get copyWith =>
      __$$LapImplCopyWithImpl<_$LapImpl>(this, _$identity);
}

abstract class _Lap implements Lap {
  const factory _Lap({required final Duration elapsed, final String? label}) =
      _$LapImpl;

  @override
  Duration get elapsed;
  @override
  String? get label;

  /// Create a copy of Lap
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LapImplCopyWith<_$LapImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
