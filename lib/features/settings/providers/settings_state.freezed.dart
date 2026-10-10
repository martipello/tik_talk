// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SettingsState {
  ThemeMode get themeMode => throw _privateConstructorUsedError;
  DialTheme get dialTheme => throw _privateConstructorUsedError;
  VoiceAnnounceInterval get voiceAnnounceInterval =>
      throw _privateConstructorUsedError;
  int get countInSeconds => throw _privateConstructorUsedError;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettingsStateCopyWith<SettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsStateCopyWith<$Res> {
  factory $SettingsStateCopyWith(
    SettingsState value,
    $Res Function(SettingsState) then,
  ) = _$SettingsStateCopyWithImpl<$Res, SettingsState>;
  @useResult
  $Res call({
    ThemeMode themeMode,
    DialTheme dialTheme,
    VoiceAnnounceInterval voiceAnnounceInterval,
    int countInSeconds,
  });
}

/// @nodoc
class _$SettingsStateCopyWithImpl<$Res, $Val extends SettingsState>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? dialTheme = null,
    Object? voiceAnnounceInterval = null,
    Object? countInSeconds = null,
  }) {
    return _then(
      _value.copyWith(
            themeMode: null == themeMode
                ? _value.themeMode
                : themeMode // ignore: cast_nullable_to_non_nullable
                      as ThemeMode,
            dialTheme: null == dialTheme
                ? _value.dialTheme
                : dialTheme // ignore: cast_nullable_to_non_nullable
                      as DialTheme,
            voiceAnnounceInterval: null == voiceAnnounceInterval
                ? _value.voiceAnnounceInterval
                : voiceAnnounceInterval // ignore: cast_nullable_to_non_nullable
                      as VoiceAnnounceInterval,
            countInSeconds: null == countInSeconds
                ? _value.countInSeconds
                : countInSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SettingsStateImplCopyWith<$Res>
    implements $SettingsStateCopyWith<$Res> {
  factory _$$SettingsStateImplCopyWith(
    _$SettingsStateImpl value,
    $Res Function(_$SettingsStateImpl) then,
  ) = __$$SettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ThemeMode themeMode,
    DialTheme dialTheme,
    VoiceAnnounceInterval voiceAnnounceInterval,
    int countInSeconds,
  });
}

/// @nodoc
class __$$SettingsStateImplCopyWithImpl<$Res>
    extends _$SettingsStateCopyWithImpl<$Res, _$SettingsStateImpl>
    implements _$$SettingsStateImplCopyWith<$Res> {
  __$$SettingsStateImplCopyWithImpl(
    _$SettingsStateImpl _value,
    $Res Function(_$SettingsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? dialTheme = null,
    Object? voiceAnnounceInterval = null,
    Object? countInSeconds = null,
  }) {
    return _then(
      _$SettingsStateImpl(
        themeMode: null == themeMode
            ? _value.themeMode
            : themeMode // ignore: cast_nullable_to_non_nullable
                  as ThemeMode,
        dialTheme: null == dialTheme
            ? _value.dialTheme
            : dialTheme // ignore: cast_nullable_to_non_nullable
                  as DialTheme,
        voiceAnnounceInterval: null == voiceAnnounceInterval
            ? _value.voiceAnnounceInterval
            : voiceAnnounceInterval // ignore: cast_nullable_to_non_nullable
                  as VoiceAnnounceInterval,
        countInSeconds: null == countInSeconds
            ? _value.countInSeconds
            : countInSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$SettingsStateImpl implements _SettingsState {
  const _$SettingsStateImpl({
    required this.themeMode,
    required this.dialTheme,
    required this.voiceAnnounceInterval,
    required this.countInSeconds,
  });

  @override
  final ThemeMode themeMode;
  @override
  final DialTheme dialTheme;
  @override
  final VoiceAnnounceInterval voiceAnnounceInterval;
  @override
  final int countInSeconds;

  @override
  String toString() {
    return 'SettingsState(themeMode: $themeMode, dialTheme: $dialTheme, voiceAnnounceInterval: $voiceAnnounceInterval, countInSeconds: $countInSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsStateImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.dialTheme, dialTheme) ||
                other.dialTheme == dialTheme) &&
            (identical(other.voiceAnnounceInterval, voiceAnnounceInterval) ||
                other.voiceAnnounceInterval == voiceAnnounceInterval) &&
            (identical(other.countInSeconds, countInSeconds) ||
                other.countInSeconds == countInSeconds));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    themeMode,
    dialTheme,
    voiceAnnounceInterval,
    countInSeconds,
  );

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      __$$SettingsStateImplCopyWithImpl<_$SettingsStateImpl>(this, _$identity);
}

abstract class _SettingsState implements SettingsState {
  const factory _SettingsState({
    required final ThemeMode themeMode,
    required final DialTheme dialTheme,
    required final VoiceAnnounceInterval voiceAnnounceInterval,
    required final int countInSeconds,
  }) = _$SettingsStateImpl;

  @override
  ThemeMode get themeMode;
  @override
  DialTheme get dialTheme;
  @override
  VoiceAnnounceInterval get voiceAnnounceInterval;
  @override
  int get countInSeconds;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
