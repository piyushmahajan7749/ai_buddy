import 'package:ai_buddy/core/util/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_review/in_app_review.dart';

class DbServiceUser {
  DbServiceUser({required this.uid});
  final String uid;

  final CollectionReference prefCollection =
      FirebaseFirestore.instance.collection('userprofile');

  /* *** Preferences db operations *** */

  Future<int> updateCredits() async {
    await prefCollection.doc(uid).update({
      'credits_left': FieldValue.increment(-1),
      'credits_used': FieldValue.increment(1),
    });
    final DocumentSnapshot doc = await prefCollection.doc(uid).get();
    final data = doc.data()! as Map<String, dynamic>;
    final creditsUsed = data['credits_used'] as int;
    return creditsUsed;
  }

  Future<Map<String, dynamic>> getUserData() async {
    final DocumentSnapshot doc = await prefCollection.doc(uid).get();
    return doc.data()! as Map<String, dynamic>;
  }

  /* *** User Preferences db operations *** */
  Future<void> createUserPref() async {
    await prefCollection.doc(uid).set({
      'name': 'New User',
      'is_pro': false,
      'credits_left': maxCredits,
      'credits_used': 0,
      'show_notification': false,
      'signup_date': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }
}
