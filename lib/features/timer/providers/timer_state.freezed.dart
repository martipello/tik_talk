// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimerState {
  TimerStatus get status => throw _privateConstructorUsedError;
  TimerMode get mode => throw _privateConstructorUsedError;
  Duration get elapsed => throw _privateConstructorUsedError;
  List<Duration> get laps => throw _privateConstructorUsedError;
  Duration get countdownFrom => throw _privateConstructorUsedError;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerStateCopyWith<TimerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerStateCopyWith<$Res> {
  factory $TimerStateCopyWith(
    TimerState value,
    $Res Function(TimerState) then,
  ) = _$TimerStateCopyWithImpl<$Res, TimerState>;
  @useResult
  $Res call({
    TimerStatus status,
    TimerMode mode,
    Duration elapsed,
    List<Duration> laps,
    Duration countdownFrom,
  });
}

/// @nodoc
class _$TimerStateCopyWithImpl<$Res, $Val extends TimerState>
    implements $TimerStateCopyWith<$Res> {
  _$TimerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? mode = null,
    Object? elapsed = null,
    Object? laps = null,
    Object? countdownFrom = null,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TimerStatus,
            mode: null == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as TimerMode,
            elapsed: null == elapsed
                ? _value.elapsed
                : elapsed // ignore: cast_nullable_to_non_nullable
                      as Duration,
            laps: null == laps
                ? _value.laps
                : laps // ignore: cast_nullable_to_non_nullable
                      as List<Duration>,
            countdownFrom: null == countdownFrom
                ? _value.countdownFrom
                : countdownFrom // ignore: cast_nullable_to_non_nullable
                      as Duration,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimerStateImplCopyWith<$Res>
    implements $TimerStateCopyWith<$Res> {
  factory _$$TimerStateImplCopyWith(
    _$TimerStateImpl value,
    $Res Function(_$TimerStateImpl) then,
  ) = __$$TimerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    TimerStatus status,
    TimerMode mode,
    Duration elapsed,
    List<Duration> laps,
    Duration countdownFrom,
  });
}

/// @nodoc
class __$$TimerStateImplCopyWithImpl<$Res>
    extends _$TimerStateCopyWithImpl<$Res, _$TimerStateImpl>
    implements _$$TimerStateImplCopyWith<$Res> {
  __$$TimerStateImplCopyWithImpl(
    _$TimerStateImpl _value,
    $Res Function(_$TimerStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? mode = null,
    Object? elapsed = null,
    Object? laps = null,
    Object? countdownFrom = null,
  }) {
    return _then(
      _$TimerStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TimerStatus,
        mode: null == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as TimerMode,
        elapsed: null == elapsed
            ? _value.elapsed
            : elapsed // ignore: cast_nullable_to_non_nullable
                  as Duration,
        laps: null == laps
            ? _value._laps
            : laps // ignore: cast_nullable_to_non_nullable
                  as List<Duration>,
        countdownFrom: null == countdownFrom
            ? _value.countdownFrom
            : countdownFrom // ignore: cast_nullable_to_non_nullable
                  as Duration,
      ),
    );
  }
}

/// @nodoc

class _$TimerStateImpl implements _TimerState {
  const _$TimerStateImpl({
    required this.status,
    required this.mode,
    required this.elapsed,
    required final List<Duration> laps,
    required this.countdownFrom,
  }) : _laps = laps;

  @override
  final TimerStatus status;
  @override
  final TimerMode mode;
  @override
  final Duration elapsed;
  final List<Duration> _laps;
  @override
  List<Duration> get laps {
    if (_laps is EqualUnmodifiableListView) return _laps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_laps);
  }

  @override
  final Duration countdownFrom;

  @override
  String toString() {
    return 'TimerState(status: $status, mode: $mode, elapsed: $elapsed, laps: $laps, countdownFrom: $countdownFrom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.elapsed, elapsed) || other.elapsed == elapsed) &&
            const DeepCollectionEquality().equals(other._laps, _laps) &&
            (identical(other.countdownFrom, countdownFrom) ||
                other.countdownFrom == countdownFrom));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    mode,
    elapsed,
    const DeepCollectionEquality().hash(_laps),
    countdownFrom,
  );

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      __$$TimerStateImplCopyWithImpl<_$TimerStateImpl>(this, _$identity);
}

abstract class _TimerState implements TimerState {
  const factory _TimerState({
    required final TimerStatus status,
    required final TimerMode mode,
    required final Duration elapsed,
    required final List<Duration> laps,
    required final Duration countdownFrom,
  }) = _$TimerStateImpl;

  @override
  TimerStatus get status;
  @override
  TimerMode get mode;
  @override
  Duration get elapsed;
  @override
  List<Duration> get laps;
  @override
  Duration get countdownFrom;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
