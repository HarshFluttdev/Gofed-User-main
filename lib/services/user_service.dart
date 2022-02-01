import 'dart:convert';

import 'package:transport/services/shared.dart';

class UserService {
  static final instance = UserService();
  var user;

  Future<void> getUser() async {
    if (await SharedData.instance.getUser() == null) return;
    user = jsonDecode(await SharedData.instance.getUser());
  }

  Future<bool> isUserLogged() async {
    if (await SharedData.instance.getUser() == null) return false;
    return true;
  }
}
