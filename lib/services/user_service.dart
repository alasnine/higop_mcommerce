import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserService {
  final _users = FirebaseFirestore.instance.collection('users');

  // Admin-only read of every registered user, newest first.
  Stream<List<AppUser>> watchAllUsers() {
    return _users.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((doc) => AppUser.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}