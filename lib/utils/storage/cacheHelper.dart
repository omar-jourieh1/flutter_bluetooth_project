//!sharedPreference store data as key : value مثل ال map
// save - get - delete - update

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheData {
  static SharedPreferences preferences;
//تعريف ال cache في قاعدة البيانات
  static Future cacheInit() async {
    //اسناد القيمة داخل ال preferences
    preferences = await SharedPreferences.getInstance();
  }

  //methods

  //! set
  static Future<bool> setData({String key, dynamic value}) async {
    //وضع قيمة الى القاعدة
    if (value is int) {
      await preferences.setInt(key, value);
      return true;
    }
    if (value is String) {
      await preferences.setString(key, value);
      return true;
    }
    if (value is bool) {
      await preferences.setBool(key, value);
      return true;
    }
    if (value is double) {
      await preferences.setDouble(key, value);
      return true;
    }

    return false;
  }

  //! get
  static dynamic getData({String key}) {
    //استرداد  قيمة الى القاعدة
    return preferences.get(
      key,
    );
  }

  //! delete
  static void deleteData({String key}) {
    //استرداد  قيمة الى القاعدة
    preferences.remove(
      key,
    );
  }
}
