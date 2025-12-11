// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_sender.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MessageSender _$MessageSenderFromJson(Map<String, dynamic> json) {
  return _MessageSender.fromJson(json);
}

/// @nodoc
mixin _$MessageSender {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_photo_url')
  String? get profilePhotoUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MessageSenderCopyWith<MessageSender> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageSenderCopyWith<$Res> {
  factory $MessageSenderCopyWith(
          MessageSender value, $Res Function(MessageSender) then) =
      _$MessageSenderCopyWithImpl<$Res, MessageSender>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'profile_photo_url') String? profilePhotoUrl});
}

/// @nodoc
class _$MessageSenderCopyWithImpl<$Res, $Val extends MessageSender>
    implements $MessageSenderCopyWith<$Res> {
  _$MessageSenderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? profilePhotoUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      profilePhotoUrl: freezed == profilePhotoUrl
          ? _value.profilePhotoUrl
          : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageSenderImplCopyWith<$Res>
    implements $MessageSenderCopyWith<$Res> {
  factory _$$MessageSenderImplCopyWith(
          _$MessageSenderImpl value, $Res Function(_$MessageSenderImpl) then) =
      __$$MessageSenderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'profile_photo_url') String? profilePhotoUrl});
}

/// @nodoc
class __$$MessageSenderImplCopyWithImpl<$Res>
    extends _$MessageSenderCopyWithImpl<$Res, _$MessageSenderImpl>
    implements _$$MessageSenderImplCopyWith<$Res> {
  __$$MessageSenderImplCopyWithImpl(
      _$MessageSenderImpl _value, $Res Function(_$MessageSenderImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? profilePhotoUrl = freezed,
  }) {
    return _then(_$MessageSenderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      profilePhotoUrl: freezed == profilePhotoUrl
          ? _value.profilePhotoUrl
          : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageSenderImpl implements _MessageSender {
  const _$MessageSenderImpl(
      {required this.id,
      @JsonKey(name: 'full_name') required this.fullName,
      @JsonKey(name: 'profile_photo_url') this.profilePhotoUrl});

  factory _$MessageSenderImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageSenderImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  @JsonKey(name: 'profile_photo_url')
  final String? profilePhotoUrl;

  @override
  String toString() {
    return 'MessageSender(id: $id, fullName: $fullName, profilePhotoUrl: $profilePhotoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageSenderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.profilePhotoUrl, profilePhotoUrl) ||
                other.profilePhotoUrl == profilePhotoUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, fullName, profilePhotoUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageSenderImplCopyWith<_$MessageSenderImpl> get copyWith =>
      __$$MessageSenderImplCopyWithImpl<_$MessageSenderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageSenderImplToJson(
      this,
    );
  }
}

abstract class _MessageSender implements MessageSender {
  const factory _MessageSender(
          {required final String id,
          @JsonKey(name: 'full_name') required final String fullName,
          @JsonKey(name: 'profile_photo_url') final String? profilePhotoUrl}) =
      _$MessageSenderImpl;

  factory _MessageSender.fromJson(Map<String, dynamic> json) =
      _$MessageSenderImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  @JsonKey(name: 'profile_photo_url')
  String? get profilePhotoUrl;
  @override
  @JsonKey(ignore: true)
  _$$MessageSenderImplCopyWith<_$MessageSenderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
