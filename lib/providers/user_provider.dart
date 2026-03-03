import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/services/user_firestore_service.dart';
import 'package:login/models/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final UserFirestoreService _service;

  UserProvider(this._service);

  Stream<List<User>> get users => _service.getUsers();

  Future<String> add(User user) {
    return _service.addUser(user);
  }

  Future<void> update(String id, User user) {
    return _service.updateUser(id, user);
  }

  Future<void> delete(String id) {
    return _service.deleteUser(id);
  }
}