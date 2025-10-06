import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_result.dart';

class StorageService {
  static const String _key = 'saved_results';

  static Future<List<SavedResult>> getSavedResults() async {
    final prefs = await SharedPreferences.getInstance();
    final String? resultsJson = prefs.getString(_key);
    
    if (resultsJson == null) return [];
    
    final List<dynamic> resultsList = json.decode(resultsJson);
    return resultsList.map((json) => SavedResult.fromJson(json)).toList();
  }

  static Future<void> saveResult(SavedResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final List<SavedResult> existingResults = await getSavedResults();
    
    existingResults.insert(0, result); // En yeni sonuç en üstte
    
    final List<Map<String, dynamic>> resultsJson = 
        existingResults.map((r) => r.toJson()).toList();
    
    await prefs.setString(_key, json.encode(resultsJson));
  }

  static Future<void> deleteResult(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<SavedResult> existingResults = await getSavedResults();
    
    existingResults.removeWhere((result) => result.id == id);
    
    final List<Map<String, dynamic>> resultsJson = 
        existingResults.map((r) => r.toJson()).toList();
    
    await prefs.setString(_key, json.encode(resultsJson));
  }

  static Future<void> clearAllResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

