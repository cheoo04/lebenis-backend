// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageSender {

 String get id;@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'profile_photo_url') String? get profilePhotoUrl;
/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageSenderCopyWith<MessageSender> get copyWith => _$MessageSenderCopyWithImpl<MessageSender>(this as MessageSender, _$identity);

  /// Serializes this MessageSender to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSender&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.profilePhotoUrl, profilePhotoUrl) || other.profilePhotoUrl == profilePhotoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,profilePhotoUrl);

@override
String toString() {
  return 'MessageSender(id: $id, fullName: $fullName, profilePhotoUrl: $profilePhotoUrl)';
}


}

/// @nodoc
abstract mixin class $MessageSenderCopyWith<$Res>  {
  factory $MessageSenderCopyWith(MessageSender value, $Res Function(MessageSender) _then) = _$MessageSenderCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'profile_photo_url') String? profilePhotoUrl
});




}
/// @nodoc
class _$MessageSenderCopyWithImpl<$Res>
    implements $MessageSenderCopyWith<$Res> {
  _$MessageSenderCopyWithImpl(this._self, this._then);

  final MessageSender _self;
  final $Res Function(MessageSender) _then;

/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? profilePhotoUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,profilePhotoUrl: freezed == profilePhotoUrl ? _self.profilePhotoUrl : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageSender].
extension MessageSenderPatterns on MessageSender {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageSender value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageSender value)  $default,){
final _that = this;
switch (_that) {
case _MessageSender():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageSender value)?  $default,){
final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'profile_photo_url')  String? profilePhotoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
return $default(_that.id,_that.fullName,_that.profilePhotoUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'profile_photo_url')  String? profilePhotoUrl)  $default,) {final _that = this;
switch (_that) {
case _MessageSender():
return $default(_that.id,_that.fullName,_that.profilePhotoUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'profile_photo_url')  String? profilePhotoUrl)?  $default,) {final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
return $default(_that.id,_that.fullName,_that.profilePhotoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageSender implements MessageSender {
  const _MessageSender({required this.id, @JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'profile_photo_url') this.profilePhotoUrl});
  factory _MessageSender.fromJson(Map<String, dynamic> json) => _$MessageSenderFromJson(json);

@override final  String id;
@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'profile_photo_url') final  String? profilePhotoUrl;

/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageSenderCopyWith<_MessageSender> get copyWith => __$MessageSenderCopyWithImpl<_MessageSender>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageSenderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageSender&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.profilePhotoUrl, profilePhotoUrl) || other.profilePhotoUrl == profilePhotoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,profilePhotoUrl);

@override
String toString() {
  return 'MessageSender(id: $id, fullName: $fullName, profilePhotoUrl: $profilePhotoUrl)';
}


}

/// @nodoc
abstract mixin class _$MessageSenderCopyWith<$Res> implements $MessageSenderCopyWith<$Res> {
  factory _$MessageSenderCopyWith(_MessageSender value, $Res Function(_MessageSender) _then) = __$MessageSenderCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'profile_photo_url') String? profilePhotoUrl
});




}
/// @nodoc
class __$MessageSenderCopyWithImpl<$Res>
    implements _$MessageSenderCopyWith<$Res> {
  __$MessageSenderCopyWithImpl(this._self, this._then);

  final _MessageSender _self;
  final $Res Function(_MessageSender) _then;

/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? profilePhotoUrl = freezed,}) {
  return _then(_MessageSender(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,profilePhotoUrl: freezed == profilePhotoUrl ? _self.profilePhotoUrl : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MessageModel {

 String get id;@JsonKey(name: 'chat_room') String get chatRoomId; MessageSender get sender;@JsonKey(name: 'message_type') MessageType get messageType; String? get text;@JsonKey(name: 'image_url') String? get imageUrl; double? get latitude; double? get longitude; bool get isRead; DateTime? get readAt; DateTime get createdAt;// Champs locaux (non sérialisés)
@JsonKey(includeFromJson: false, includeToJson: false) MessageStatus get status;@JsonKey(includeFromJson: false, includeToJson: false) bool get isMine;
/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageModelCopyWith<MessageModel> get copyWith => _$MessageModelCopyWithImpl<MessageModel>(this as MessageModel, _$identity);

  /// Serializes this MessageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.chatRoomId, chatRoomId) || other.chatRoomId == chatRoomId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.text, text) || other.text == text)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.isMine, isMine) || other.isMine == isMine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,chatRoomId,sender,messageType,text,imageUrl,latitude,longitude,isRead,readAt,createdAt,status,isMine);

@override
String toString() {
  return 'MessageModel(id: $id, chatRoomId: $chatRoomId, sender: $sender, messageType: $messageType, text: $text, imageUrl: $imageUrl, latitude: $latitude, longitude: $longitude, isRead: $isRead, readAt: $readAt, createdAt: $createdAt, status: $status, isMine: $isMine)';
}


}

/// @nodoc
abstract mixin class $MessageModelCopyWith<$Res>  {
  factory $MessageModelCopyWith(MessageModel value, $Res Function(MessageModel) _then) = _$MessageModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'chat_room') String chatRoomId, MessageSender sender,@JsonKey(name: 'message_type') MessageType messageType, String? text,@JsonKey(name: 'image_url') String? imageUrl, double? latitude, double? longitude, bool isRead, DateTime? readAt, DateTime createdAt,@JsonKey(includeFromJson: false, includeToJson: false) MessageStatus status,@JsonKey(includeFromJson: false, includeToJson: false) bool isMine
});


$MessageSenderCopyWith<$Res> get sender;

}
/// @nodoc
class _$MessageModelCopyWithImpl<$Res>
    implements $MessageModelCopyWith<$Res> {
  _$MessageModelCopyWithImpl(this._self, this._then);

  final MessageModel _self;
  final $Res Function(MessageModel) _then;

/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chatRoomId = null,Object? sender = null,Object? messageType = null,Object? text = freezed,Object? imageUrl = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? isRead = null,Object? readAt = freezed,Object? createdAt = null,Object? status = null,Object? isMine = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatRoomId: null == chatRoomId ? _self.chatRoomId : chatRoomId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as MessageSender,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as MessageType,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MessageStatus,isMine: null == isMine ? _self.isMine : isMine // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageSenderCopyWith<$Res> get sender {
  
  return $MessageSenderCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// Adds pattern-matching-related methods to [MessageModel].
extension MessageModelPatterns on MessageModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageModel value)  $default,){
final _that = this;
switch (_that) {
case _MessageModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageModel value)?  $default,){
final _that = this;
switch (_that) {
case _MessageModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'chat_room')  String chatRoomId,  MessageSender sender, @JsonKey(name: 'message_type')  MessageType messageType,  String? text, @JsonKey(name: 'image_url')  String? imageUrl,  double? latitude,  double? longitude,  bool isRead,  DateTime? readAt,  DateTime createdAt, @JsonKey(includeFromJson: false, includeToJson: false)  MessageStatus status, @JsonKey(includeFromJson: false, includeToJson: false)  bool isMine)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageModel() when $default != null:
return $default(_that.id,_that.chatRoomId,_that.sender,_that.messageType,_that.text,_that.imageUrl,_that.latitude,_that.longitude,_that.isRead,_that.readAt,_that.createdAt,_that.status,_that.isMine);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'chat_room')  String chatRoomId,  MessageSender sender, @JsonKey(name: 'message_type')  MessageType messageType,  String? text, @JsonKey(name: 'image_url')  String? imageUrl,  double? latitude,  double? longitude,  bool isRead,  DateTime? readAt,  DateTime createdAt, @JsonKey(includeFromJson: false, includeToJson: false)  MessageStatus status, @JsonKey(includeFromJson: false, includeToJson: false)  bool isMine)  $default,) {final _that = this;
switch (_that) {
case _MessageModel():
return $default(_that.id,_that.chatRoomId,_that.sender,_that.messageType,_that.text,_that.imageUrl,_that.latitude,_that.longitude,_that.isRead,_that.readAt,_that.createdAt,_that.status,_that.isMine);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'chat_room')  String chatRoomId,  MessageSender sender, @JsonKey(name: 'message_type')  MessageType messageType,  String? text, @JsonKey(name: 'image_url')  String? imageUrl,  double? latitude,  double? longitude,  bool isRead,  DateTime? readAt,  DateTime createdAt, @JsonKey(includeFromJson: false, includeToJson: false)  MessageStatus status, @JsonKey(includeFromJson: false, includeToJson: false)  bool isMine)?  $default,) {final _that = this;
switch (_that) {
case _MessageModel() when $default != null:
return $default(_that.id,_that.chatRoomId,_that.sender,_that.messageType,_that.text,_that.imageUrl,_that.latitude,_that.longitude,_that.isRead,_that.readAt,_that.createdAt,_that.status,_that.isMine);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageModel implements MessageModel {
  const _MessageModel({required this.id, @JsonKey(name: 'chat_room') required this.chatRoomId, required this.sender, @JsonKey(name: 'message_type') required this.messageType, this.text, @JsonKey(name: 'image_url') this.imageUrl, this.latitude, this.longitude, this.isRead = false, this.readAt, required this.createdAt, @JsonKey(includeFromJson: false, includeToJson: false) this.status = MessageStatus.sent, @JsonKey(includeFromJson: false, includeToJson: false) this.isMine = false});
  factory _MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'chat_room') final  String chatRoomId;
@override final  MessageSender sender;
@override@JsonKey(name: 'message_type') final  MessageType messageType;
@override final  String? text;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override final  double? latitude;
@override final  double? longitude;
@override@JsonKey() final  bool isRead;
@override final  DateTime? readAt;
@override final  DateTime createdAt;
// Champs locaux (non sérialisés)
@override@JsonKey(includeFromJson: false, includeToJson: false) final  MessageStatus status;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool isMine;

/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageModelCopyWith<_MessageModel> get copyWith => __$MessageModelCopyWithImpl<_MessageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.chatRoomId, chatRoomId) || other.chatRoomId == chatRoomId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.text, text) || other.text == text)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.isMine, isMine) || other.isMine == isMine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,chatRoomId,sender,messageType,text,imageUrl,latitude,longitude,isRead,readAt,createdAt,status,isMine);

@override
String toString() {
  return 'MessageModel(id: $id, chatRoomId: $chatRoomId, sender: $sender, messageType: $messageType, text: $text, imageUrl: $imageUrl, latitude: $latitude, longitude: $longitude, isRead: $isRead, readAt: $readAt, createdAt: $createdAt, status: $status, isMine: $isMine)';
}


}

/// @nodoc
abstract mixin class _$MessageModelCopyWith<$Res> implements $MessageModelCopyWith<$Res> {
  factory _$MessageModelCopyWith(_MessageModel value, $Res Function(_MessageModel) _then) = __$MessageModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'chat_room') String chatRoomId, MessageSender sender,@JsonKey(name: 'message_type') MessageType messageType, String? text,@JsonKey(name: 'image_url') String? imageUrl, double? latitude, double? longitude, bool isRead, DateTime? readAt, DateTime createdAt,@JsonKey(includeFromJson: false, includeToJson: false) MessageStatus status,@JsonKey(includeFromJson: false, includeToJson: false) bool isMine
});


@override $MessageSenderCopyWith<$Res> get sender;

}
/// @nodoc
class __$MessageModelCopyWithImpl<$Res>
    implements _$MessageModelCopyWith<$Res> {
  __$MessageModelCopyWithImpl(this._self, this._then);

  final _MessageModel _self;
  final $Res Function(_MessageModel) _then;

/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chatRoomId = null,Object? sender = null,Object? messageType = null,Object? text = freezed,Object? imageUrl = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? isRead = null,Object? readAt = freezed,Object? createdAt = null,Object? status = null,Object? isMine = null,}) {
  return _then(_MessageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatRoomId: null == chatRoomId ? _self.chatRoomId : chatRoomId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as MessageSender,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as MessageType,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MessageStatus,isMine: null == isMine ? _self.isMine : isMine // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageSenderCopyWith<$Res> get sender {
  
  return $MessageSenderCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}

// dart format on
