import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    this.name,
    this.showNotification,
    this.isPro,
    this.creditsLeft,
    this.creditsUsed,
    this.signupDate,
    this.updatedAt,
  });
  UserModel.fromJson(Map<String, Object?> data)
      : this(
          name: data['name'] as String?,
          showNotification: data['show_notification']! as bool,
          isPro: data['is_pro']! as bool,
          creditsLeft: data['creditsLeft']! as int,
          creditsUsed: data['creditsUsed']! as int,
          signupDate: data['signup_date']! as Timestamp,
          updatedAt: data['updatedAt']! as Timestamp,
        );
  final String? name;
  final bool? showNotification;
  bool? isPro;
  int? creditsLeft;
  int? creditsUsed;
  final Timestamp? signupDate;
  final Timestamp? updatedAt;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'show_notification': showNotification,
      'is_pro': isPro,
      'creditsLeft': creditsLeft,
      'creditsUsed': creditsUsed,
      'signup_date': signupDate,
      'updatedAt': updatedAt,
    };
  }
}
