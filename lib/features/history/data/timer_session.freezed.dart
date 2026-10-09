// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimerSession {
  int? get id => throw _privateConstructorUsedError;
  TimerMode get mode => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;
  List<Duration> get laps => throw _privateConstructorUsedError;

  /// Create a copy of TimerSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerSessionCopyWith<TimerSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerSessionCopyWith<$Res> {
  factory $TimerSessionCopyWith(
    TimerSession value,
    $Res Function(TimerSession) then,
  ) = _$TimerSessionCopyWithImpl<$Res, TimerSession>;
  @useResult
  $Res call({
    int? id,
    TimerMode mode,
    DateTime completedAt,
    Duration duration,
    List<Duration> laps,
  });
}

/// @nodoc
class _$TimerSessionCopyWithImpl<$Res, $Val extends TimerSession>
    implements $TimerSessionCopyWith<$Res> {
  _$TimerSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? mode = null,
    Object? completedAt = null,
    Object? duration = null,
    Object? laps = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            mode: null == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as TimerMode,
            completedAt: null == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as Duration,
            laps: null == laps
                ? _value.laps
                : laps // ignore: cast_nullable_to_non_nullable
                      as List<Duration>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimerSessionImplCopyWith<$Res>
    implements $TimerSessionCopyWith<$Res> {
  factory _$$TimerSessionImplCopyWith(
    _$TimerSessionImpl value,
    $Res Function(_$TimerSessionImpl) then,
  ) = __$$TimerSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    TimerMode mode,
    DateTime completedAt,
    Duration duration,
    List<Duration> laps,
  });
}

/// @nodoc
class __$$TimerSessionImplCopyWithImpl<$Res>
    extends _$TimerSessionCopyWithImpl<$Res, _$TimerSessionImpl>
    implements _$$TimerSessionImplCopyWith<$Res> {
  __$$TimerSessionImplCopyWithImpl(
    _$TimerSessionImpl _value,
    $Res Function(_$TimerSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? mode = null,
    Object? completedAt = null,
    Object? duration = null,
    Object? laps = null,
  }) {
    return _then(
      _$TimerSessionImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        mode: null == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as TimerMode,
        completedAt: null == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as Duration,
        laps: null == laps
            ? _value._laps
            : laps // ignore: cast_nullable_to_non_nullable
                  as List<Duration>,
      ),
    );
  }
}

/// @nodoc

class _$TimerSessionImpl implements _TimerSession {
  const _$TimerSessionImpl({
    required this.id,
    required this.mode,
    required this.completedAt,
    required this.duration,
    required final List<Duration> laps,
  }) : _laps = laps;

  @override
  final int? id;
  @override
  final TimerMode mode;
  @override
  final DateTime completedAt;
  @override
  final Duration duration;
  final List<Duration> _laps;
  @override
  List<Duration> get laps {
    if (_laps is EqualUnmodifiableListView) return _laps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_laps);
  }

  @override
  String toString() {
    return 'TimerSession(id: $id, mode: $mode, completedAt: $completedAt, duration: $duration, laps: $laps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            const DeepCollectionEquality().equals(other._laps, _laps));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    mode,
    completedAt,
    duration,
    const DeepCollectionEquality().hash(_laps),
  );

  /// Create a copy of TimerSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerSessionImplCopyWith<_$TimerSessionImpl> get copyWith =>
      __$$TimerSessionImplCopyWithImpl<_$TimerSessionImpl>(this, _$identity);
}

abstract class _TimerSession implements TimerSession {
  const factory _TimerSession({
    required final int? id,
    required final TimerMode mode,
    required final DateTime completedAt,
    required final Duration duration,
    required final List<Duration> laps,
  }) = _$TimerSessionImpl;

  @override
  int? get id;
  @override
  TimerMode get mode;
  @override
  DateTime get completedAt;
  @override
  Duration get duration;
  @override
  List<Duration> get laps;

  /// Create a copy of TimerSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerSessionImplCopyWith<_$TimerSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
