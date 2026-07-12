// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'section.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SectionInfo _$SectionInfoFromJson(Map<String, dynamic> json) {
  return _SectionInfo.fromJson(json);
}

/// @nodoc
mixin _$SectionInfo {
  @JsonKey(name: 'jsonPropertyName')
  String get jsonPropertyName => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this SectionInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SectionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SectionInfoCopyWith<SectionInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SectionInfoCopyWith<$Res> {
  factory $SectionInfoCopyWith(
          SectionInfo value, $Res Function(SectionInfo) then) =
      _$SectionInfoCopyWithImpl<$Res, SectionInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: 'jsonPropertyName') String jsonPropertyName,
      String description});
}

/// @nodoc
class _$SectionInfoCopyWithImpl<$Res, $Val extends SectionInfo>
    implements $SectionInfoCopyWith<$Res> {
  _$SectionInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SectionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jsonPropertyName = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      jsonPropertyName: null == jsonPropertyName
          ? _value.jsonPropertyName
          : jsonPropertyName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SectionInfoImplCopyWith<$Res>
    implements $SectionInfoCopyWith<$Res> {
  factory _$$SectionInfoImplCopyWith(
          _$SectionInfoImpl value, $Res Function(_$SectionInfoImpl) then) =
      __$$SectionInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'jsonPropertyName') String jsonPropertyName,
      String description});
}

/// @nodoc
class __$$SectionInfoImplCopyWithImpl<$Res>
    extends _$SectionInfoCopyWithImpl<$Res, _$SectionInfoImpl>
    implements _$$SectionInfoImplCopyWith<$Res> {
  __$$SectionInfoImplCopyWithImpl(
      _$SectionInfoImpl _value, $Res Function(_$SectionInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SectionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jsonPropertyName = null,
    Object? description = null,
  }) {
    return _then(_$SectionInfoImpl(
      jsonPropertyName: null == jsonPropertyName
          ? _value.jsonPropertyName
          : jsonPropertyName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SectionInfoImpl implements _SectionInfo {
  const _$SectionInfoImpl(
      {@JsonKey(name: 'jsonPropertyName') required this.jsonPropertyName,
      required this.description});

  factory _$SectionInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SectionInfoImplFromJson(json);

  @override
  @JsonKey(name: 'jsonPropertyName')
  final String jsonPropertyName;
  @override
  final String description;

  @override
  String toString() {
    return 'SectionInfo(jsonPropertyName: $jsonPropertyName, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SectionInfoImpl &&
            (identical(other.jsonPropertyName, jsonPropertyName) ||
                other.jsonPropertyName == jsonPropertyName) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, jsonPropertyName, description);

  /// Create a copy of SectionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SectionInfoImplCopyWith<_$SectionInfoImpl> get copyWith =>
      __$$SectionInfoImplCopyWithImpl<_$SectionInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SectionInfoImplToJson(
      this,
    );
  }
}

abstract class _SectionInfo implements SectionInfo {
  const factory _SectionInfo(
      {@JsonKey(name: 'jsonPropertyName')
      required final String jsonPropertyName,
      required final String description}) = _$SectionInfoImpl;

  factory _SectionInfo.fromJson(Map<String, dynamic> json) =
      _$SectionInfoImpl.fromJson;

  @override
  @JsonKey(name: 'jsonPropertyName')
  String get jsonPropertyName;
  @override
  String get description;

  /// Create a copy of SectionInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SectionInfoImplCopyWith<_$SectionInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
