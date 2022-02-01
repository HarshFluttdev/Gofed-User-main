import 'package:shared_preferences/shared_preferences.dart';

class SharedData {
  static final SharedData instance = SharedData();
  SharedPreferences _pref;

  _init() async {
    try {
      _pref = await SharedPreferences.getInstance();
    } catch (e) {
      print(e);
    }
  }

  userLogged() async {
    try {
      await _init();

      if (!_pref.containsKey('user_id')) {
        return false;
      }
      return true;
    } catch (e) {
      print(e);
    }
  }

  getUser() async {
    try {
      await _init();

      if (!_pref.containsKey('user_id')) {
        return false;
      }
      return await _pref.getString('user_id');
    } catch (e) {
      print(e);
    }
  }

  setUser(String value) async {
    try {
      await _init();
      await _pref.setString('user_id', value);
      return true;
    } catch (e) {
      print(e);
    }
  }

  logout() async {
    try {
      await _init();
      return await _pref.clear();
    } catch (e) {
      print(e);
    }
  }
}