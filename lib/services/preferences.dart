import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PreferencesService {
  // Singleton instance
  static final PreferencesService _instance = PreferencesService._internal();

  // Factory constructor
  factory PreferencesService() => _instance;

  // Private constructor
  PreferencesService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<String> cachedBlackList = [];

  // ! Add some try catch blocks

  Future<bool> savePreferences(String newItem) async {
    if (cachedBlackList.contains(newItem)){
      Fluttertoast.showToast(
        msg: "Item already exists!",
        backgroundColor: const Color.fromARGB(255, 204, 54, 44),
        textColor: Colors.white,
        fontSize: 16,
      );
      return false;
    }
    cachedBlackList.add(newItem);
    final jsonBlacklistString = jsonEncode(cachedBlackList);
    await _storage.write(key: 'blacklist', value: jsonBlacklistString);
    return true;
  }

  Future<List<String>> readPreferences() async {
    final jsonString = await _storage.read(key: 'blacklist');
    if (jsonString == null) {
      cachedBlackList = [];
      return [];
    }

    final List<dynamic> decoded = jsonDecode(jsonString);
    cachedBlackList = decoded.cast<String>();
    return List<String>.from(cachedBlackList); //  Returns a copy
  }

  Future<List<String>> deletePreference(String item) async {
    cachedBlackList.remove(item);
    final jsonBlacklistString = jsonEncode(cachedBlackList);
    await _storage.write(key: 'blacklist', value: jsonBlacklistString);
    // return cachedBlackList;
    return List<String>.from(cachedBlackList);
  }

}
