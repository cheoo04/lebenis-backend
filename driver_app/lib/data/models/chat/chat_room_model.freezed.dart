// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_room_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatParticipant {

 String get id; String get fullName; String get phoneNumber; String get userType; String? get profilePhotoUrl;
/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatParticipantCopyWith<ChatParticipant> get copyWith => _$ChatParticipantCopyWithImpl<ChatParticipant>(this as ChatParticipant, _$identity);

  /// Serializes this ChatParticipant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatParticipant&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.userType, userType) || other.userType == userType)&&(identical(other.profilePhotoUrl, profilePhotoUrl) || other.profilePhotoUrl == profilePhotoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phoneNumber,userType,profilePhotoUrl);

@override
String toString() {
  return 'ChatParticipant(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, userType: $userType, profilePhotoUrl: $profilePhotoUrl)';
}


}

/// @nodoc
abstract mixin class $ChatParticipantCopyWith<$Res>  {
  factory $ChatParticipantCopyWith(ChatParticipant value, $Res Function(ChatParticipant) _then) = _$ChatParticipantCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String phoneNumber, String userType, String? profilePhotoUrl
});




}
/// @nodoc
class _$ChatParticipantCopyWithImpl<$Res>
    implements $ChatParticipantCopyWith<$Res> {
  _$ChatParticipantCopyWithImpl(this._self, this._then);

  final ChatParticipant _self;
  final $Res Function(ChatParticipant) _then;

/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? phoneNumber = null,Object? userType = null,Object? profilePhotoUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as String,profilePhotoUrl: freezed == profilePhotoUrl ? _self.profilePhotoUrl : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatParticipant].
extension ChatParticipantPatterns on ChatParticipant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatParticipant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatParticipant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatParticipant value)  $default,){
final _that = this;
switch (_that) {
case _ChatParticipant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatParticipant value)?  $default,){
final _that = this;
switch (_that) {
case _ChatParticipant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String phoneNumber,  String userType,  String? profilePhotoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatParticipant() when $default != null:
return $default(_that.id,_that.fullName,_that.phoneNumber,_that.userType,_that.profilePhotoUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String phoneNumber,  String userType,  String? profilePhotoUrl)  $default,) {final _that = this;
switch (_that) {
case _ChatParticipant():
return $default(_that.id,_that.fullName,_that.phoneNumber,_that.userType,_that.profilePhotoUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String phoneNumber,  String userType,  String? profilePhotoUrl)?  $default,) {final _that = this;
switch (_that) {
case _ChatParticipant() when $default != null:
return $default(_that.id,_that.fullName,_that.phoneNumber,_that.userType,_that.profilePhotoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatParticipant implements ChatParticipant {
  const _ChatParticipant({required this.id, required this.fullName, required this.phoneNumber, required this.userType, this.profilePhotoUrl});
  factory _ChatParticipant.fromJson(Map<String, dynamic> json) => _$ChatParticipantFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String phoneNumber;
@override final  String userType;
@override final  String? profilePhotoUrl;

/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatParticipantCopyWith<_ChatParticipant> get copyWith => __$ChatParticipantCopyWithImpl<_ChatParticipant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatParticipantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatParticipant&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.userType, userType) || other.userType == userType)&&(identical(other.profilePhotoUrl, profilePhotoUrl) || other.profilePhotoUrl == profilePhotoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phoneNumber,userType,profilePhotoUrl);

@override
String toString() {
  return 'ChatParticipant(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, userType: $userType, profilePhotoUrl: $profilePhotoUrl)';
}


}

/// @nodoc
abstract mixin class _$ChatParticipantCopyWith<$Res> implements $ChatParticipantCopyWith<$Res> {
  factory _$ChatParticipantCopyWith(_ChatParticipant value, $Res Function(_ChatParticipant) _then) = __$ChatParticipantCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String phoneNumber, String userType, String? profilePhotoUrl
});




}
/// @nodoc
class __$ChatParticipantCopyWithImpl<$Res>
    implements _$ChatParticipantCopyWith<$Res> {
  __$ChatParticipantCopyWithImpl(this._self, this._then);

  final _ChatParticipant _self;
  final $Res Function(_ChatParticipant) _then;

/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? phoneNumber = null,Object? userType = null,Object? profilePhotoUrl = freezed,}) {
  return _then(_ChatParticipant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as String,profilePhotoUrl: freezed == profilePhotoUrl ? _self.profilePhotoUrl : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DeliveryInfo {

 String get id; String get trackingNumber; String? get pickupAddress; String? get deliveryAddress;
/// Create a copy of DeliveryInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryInfoCopyWith<DeliveryInfo> get copyWith => _$DeliveryInfoCopyWithImpl<DeliveryInfo>(this as DeliveryInfo, _$identity);

  /// Serializes this DeliveryInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trackingNumber,pickupAddress,deliveryAddress);

@override
String toString() {
  return 'DeliveryInfo(id: $id, trackingNumber: $trackingNumber, pickupAddress: $pickupAddress, deliveryAddress: $deliveryAddress)';
}


}

/// @nodoc
abstract mixin class $DeliveryInfoCopyWith<$Res>  {
  factory $DeliveryInfoCopyWith(DeliveryInfo value, $Res Function(DeliveryInfo) _then) = _$DeliveryInfoCopyWithImpl;
@useResult
$Res call({
 String id, String trackingNumber, String? pickupAddress, String? deliveryAddress
});




}
/// @nodoc
class _$DeliveryInfoCopyWithImpl<$Res>
    implements $DeliveryInfoCopyWith<$Res> {
  _$DeliveryInfoCopyWithImpl(this._self, this._then);

  final DeliveryInfo _self;
  final $Res Function(DeliveryInfo) _then;

/// Create a copy of DeliveryInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trackingNumber = null,Object? pickupAddress = freezed,Object? deliveryAddress = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trackingNumber: null == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String,pickupAddress: freezed == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String?,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryInfo].
extension DeliveryInfoPatterns on DeliveryInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryInfo value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryInfo value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String trackingNumber,  String? pickupAddress,  String? deliveryAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryInfo() when $default != null:
return $default(_that.id,_that.trackingNumber,_that.pickupAddress,_that.deliveryAddress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String trackingNumber,  String? pickupAddress,  String? deliveryAddress)  $default,) {final _that = this;
switch (_that) {
case _DeliveryInfo():
return $default(_that.id,_that.trackingNumber,_that.pickupAddress,_that.deliveryAddress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String trackingNumber,  String? pickupAddress,  String? deliveryAddress)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryInfo() when $default != null:
return $default(_that.id,_that.trackingNumber,_that.pickupAddress,_that.deliveryAddress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeliveryInfo implements DeliveryInfo {
  const _DeliveryInfo({required this.id, required this.trackingNumber, this.pickupAddress, this.deliveryAddress});
  factory _DeliveryInfo.fromJson(Map<String, dynamic> json) => _$DeliveryInfoFromJson(json);

@override final  String id;
@override final  String trackingNumber;
@override final  String? pickupAddress;
@override final  String? deliveryAddress;

/// Create a copy of DeliveryInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryInfoCopyWith<_DeliveryInfo> get copyWith => __$DeliveryInfoCopyWithImpl<_DeliveryInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trackingNumber,pickupAddress,deliveryAddress);

@override
String toString() {
  return 'DeliveryInfo(id: $id, trackingNumber: $trackingNumber, pickupAddress: $pickupAddress, deliveryAddress: $deliveryAddress)';
}


}

/// @nodoc
abstract mixin class _$DeliveryInfoCopyWith<$Res> implements $DeliveryInfoCopyWith<$Res> {
  factory _$DeliveryInfoCopyWith(_DeliveryInfo value, $Res Function(_DeliveryInfo) _then) = __$DeliveryInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String trackingNumber, String? pickupAddress, String? deliveryAddress
});




}
/// @nodoc
class __$DeliveryInfoCopyWithImpl<$Res>
    implements _$DeliveryInfoCopyWith<$Res> {
  __$DeliveryInfoCopyWithImpl(this._self, this._then);

  final _DeliveryInfo _self;
  final $Res Function(_DeliveryInfo) _then;

/// Create a copy of DeliveryInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trackingNumber = null,Object? pickupAddress = freezed,Object? deliveryAddress = freezed,}) {
  return _then(_DeliveryInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trackingNumber: null == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String,pickupAddress: freezed == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String?,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChatRoomModel {

 String get id; RoomType get roomType; ChatParticipant get otherParticipant; DeliveryInfo? get deliveryInfo; String? get lastMessageText; DateTime? get lastMessageAt; int get unreadCount; bool get isArchived; DateTime get createdAt; String? get firebasePath;
/// Create a copy of ChatRoomModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatRoomModelCopyWith<ChatRoomModel> get copyWith => _$ChatRoomModelCopyWithImpl<ChatRoomModel>(this as ChatRoomModel, _$identity);

  /// Serializes this ChatRoomModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatRoomModel&&(identical(other.id, id) || other.id == id)&&(identical(other.roomType, roomType) || other.roomType == roomType)&&(identical(other.otherParticipant, otherParticipant) || other.otherParticipant == otherParticipant)&&(identical(other.deliveryInfo, deliveryInfo) || other.deliveryInfo == deliveryInfo)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.firebasePath, firebasePath) || other.firebasePath == firebasePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,roomType,otherParticipant,deliveryInfo,lastMessageText,lastMessageAt,unreadCount,isArchived,createdAt,firebasePath);

@override
String toString() {
  return 'ChatRoomModel(id: $id, roomType: $roomType, otherParticipant: $otherParticipant, deliveryInfo: $deliveryInfo, lastMessageText: $lastMessageText, lastMessageAt: $lastMessageAt, unreadCount: $unreadCount, isArchived: $isArchived, createdAt: $createdAt, firebasePath: $firebasePath)';
}


}

/// @nodoc
abstract mixin class $ChatRoomModelCopyWith<$Res>  {
  factory $ChatRoomModelCopyWith(ChatRoomModel value, $Res Function(ChatRoomModel) _then) = _$ChatRoomModelCopyWithImpl;
@useResult
$Res call({
 String id, RoomType roomType, ChatParticipant otherParticipant, DeliveryInfo? deliveryInfo, String? lastMessageText, DateTime? lastMessageAt, int unreadCount, bool isArchived, DateTime createdAt, String? firebasePath
});


$ChatParticipantCopyWith<$Res> get otherParticipant;$DeliveryInfoCopyWith<$Res>? get deliveryInfo;

}
/// @nodoc
class _$ChatRoomModelCopyWithImpl<$Res>
    implements $ChatRoomModelCopyWith<$Res> {
  _$ChatRoomModelCopyWithImpl(this._self, this._then);

  final ChatRoomModel _self;
  final $Res Function(ChatRoomModel) _then;

/// Create a copy of ChatRoomModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? roomType = null,Object? otherParticipant = null,Object? deliveryInfo = freezed,Object? lastMessageText = freezed,Object? lastMessageAt = freezed,Object? unreadCount = null,Object? isArchived = null,Object? createdAt = null,Object? firebasePath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomType: null == roomType ? _self.roomType : roomType // ignore: cast_nullable_to_non_nullable
as RoomType,otherParticipant: null == otherParticipant ? _self.otherParticipant : otherParticipant // ignore: cast_nullable_to_non_nullable
as ChatParticipant,deliveryInfo: freezed == deliveryInfo ? _self.deliveryInfo : deliveryInfo // ignore: cast_nullable_to_non_nullable
as DeliveryInfo?,lastMessageText: freezed == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,firebasePath: freezed == firebasePath ? _self.firebasePath : firebasePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ChatRoomModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatParticipantCopyWith<$Res> get otherParticipant {
  
  return $ChatParticipantCopyWith<$Res>(_self.otherParticipant, (value) {
    return _then(_self.copyWith(otherParticipant: value));
  });
}/// Create a copy of ChatRoomModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryInfoCopyWith<$Res>? get deliveryInfo {
    if (_self.deliveryInfo == null) {
    return null;
  }

  return $DeliveryInfoCopyWith<$Res>(_self.deliveryInfo!, (value) {
    return _then(_self.copyWith(deliveryInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatRoomModel].
extension ChatRoomModelPatterns on ChatRoomModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatRoomModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatRoomModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatRoomModel value)  $default,){
final _that = this;
switch (_that) {
case _ChatRoomModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatRoomModel value)?  $default,){
final _that = this;
switch (_that) {
case _ChatRoomModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  RoomType roomType,  ChatParticipant otherParticipant,  DeliveryInfo? deliveryInfo,  String? lastMessageText,  DateTime? lastMessageAt,  int unreadCount,  bool isArchived,  DateTime createdAt,  String? firebasePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatRoomModel() when $default != null:
return $default(_that.id,_that.roomType,_that.otherParticipant,_that.deliveryInfo,_that.lastMessageText,_that.lastMessageAt,_that.unreadCount,_that.isArchived,_that.createdAt,_that.firebasePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  RoomType roomType,  ChatParticipant otherParticipant,  DeliveryInfo? deliveryInfo,  String? lastMessageText,  DateTime? lastMessageAt,  int unreadCount,  bool isArchived,  DateTime createdAt,  String? firebasePath)  $default,) {final _that = this;
switch (_that) {
case _ChatRoomModel():
return $default(_that.id,_that.roomType,_that.otherParticipant,_that.deliveryInfo,_that.lastMessageText,_that.lastMessageAt,_that.unreadCount,_that.isArchived,_that.createdAt,_that.firebasePath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  RoomType roomType,  ChatParticipant otherParticipant,  DeliveryInfo? deliveryInfo,  String? lastMessageText,  DateTime? lastMessageAt,  int unreadCount,  bool isArchived,  DateTime createdAt,  String? firebasePath)?  $default,) {final _that = this;
switch (_that) {
case _ChatRoomModel() when $default != null:
return $default(_that.id,_that.roomType,_that.otherParticipant,_that.deliveryInfo,_that.lastMessageText,_that.lastMessageAt,_that.unreadCount,_that.isArchived,_that.createdAt,_that.firebasePath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatRoomModel implements ChatRoomModel {
  const _ChatRoomModel({required this.id, required this.roomType, required this.otherParticipant, this.deliveryInfo, this.lastMessageText, this.lastMessageAt, this.unreadCount = 0, this.isArchived = false, required this.createdAt, this.firebasePath});
  factory _ChatRoomModel.fromJson(Map<String, dynamic> json) => _$ChatRoomModelFromJson(json);

@override final  String id;
@override final  RoomType roomType;
@override final  ChatParticipant otherParticipant;
@override final  DeliveryInfo? deliveryInfo;
@override final  String? lastMessageText;
@override final  DateTime? lastMessageAt;
@override@JsonKey() final  int unreadCount;
@override@JsonKey() final  bool isArchived;
@override final  DateTime createdAt;
@override final  String? firebasePath;

/// Create a copy of ChatRoomModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatRoomModelCopyWith<_ChatRoomModel> get copyWith => __$ChatRoomModelCopyWithImpl<_ChatRoomModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatRoomModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatRoomModel&&(identical(other.id, id) || other.id == id)&&(identical(other.roomType, roomType) || other.roomType == roomType)&&(identical(other.otherParticipant, otherParticipant) || other.otherParticipant == otherParticipant)&&(identical(other.deliveryInfo, deliveryInfo) || other.deliveryInfo == deliveryInfo)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.firebasePath, firebasePath) || other.firebasePath == firebasePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,roomType,otherParticipant,deliveryInfo,lastMessageText,lastMessageAt,unreadCount,isArchived,createdAt,firebasePath);

@override
String toString() {
  return 'ChatRoomModel(id: $id, roomType: $roomType, otherParticipant: $otherParticipant, deliveryInfo: $deliveryInfo, lastMessageText: $lastMessageText, lastMessageAt: $lastMessageAt, unreadCount: $unreadCount, isArchived: $isArchived, createdAt: $createdAt, firebasePath: $firebasePath)';
}


}

/// @nodoc
abstract mixin class _$ChatRoomModelCopyWith<$Res> implements $ChatRoomModelCopyWith<$Res> {
  factory _$ChatRoomModelCopyWith(_ChatRoomModel value, $Res Function(_ChatRoomModel) _then) = __$ChatRoomModelCopyWithImpl;
@override @useResult
$Res call({
 String id, RoomType roomType, ChatParticipant otherParticipant, DeliveryInfo? deliveryInfo, String? lastMessageText, DateTime? lastMessageAt, int unreadCount, bool isArchived, DateTime createdAt, String? firebasePath
});


@override $ChatParticipantCopyWith<$Res> get otherParticipant;@override $DeliveryInfoCopyWith<$Res>? get deliveryInfo;

}
/// @nodoc
class __$ChatRoomModelCopyWithImpl<$Res>
    implements _$ChatRoomModelCopyWith<$Res> {
  __$ChatRoomModelCopyWithImpl(this._self, this._then);

  final _ChatRoomModel _self;
  final $Res Function(_ChatRoomModel) _then;

/// Create a copy of ChatRoomModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? roomType = null,Object? otherParticipant = null,Object? deliveryInfo = freezed,Object? lastMessageText = freezed,Object? lastMessageAt = freezed,Object? unreadCount = null,Object? isArchived = null,Object? createdAt = null,Object? firebasePath = freezed,}) {
  return _then(_ChatRoomModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomType: null == roomType ? _self.roomType : roomType // ignore: cast_nullable_to_non_nullable
as RoomType,otherParticipant: null == otherParticipant ? _self.otherParticipant : otherParticipant // ignore: cast_nullable_to_non_nullable
as ChatParticipant,deliveryInfo: freezed == deliveryInfo ? _self.deliveryInfo : deliveryInfo // ignore: cast_nullable_to_non_nullable
as DeliveryInfo?,lastMessageText: freezed == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,firebasePath: freezed == firebasePath ? _self.firebasePath : firebasePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ChatRoomModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatParticipantCopyWith<$Res> get otherParticipant {
  
  return $ChatParticipantCopyWith<$Res>(_self.otherParticipant, (value) {
    return _then(_self.copyWith(otherParticipant: value));
  });
}/// Create a copy of ChatRoomModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryInfoCopyWith<$Res>? get deliveryInfo {
    if (_self.deliveryInfo == null) {
    return null;
  }

  return $DeliveryInfoCopyWith<$Res>(_self.deliveryInfo!, (value) {
    return _then(_self.copyWith(deliveryInfo: value));
  });
}
}

// dart format on
