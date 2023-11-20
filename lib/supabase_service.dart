import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SupabaseService {
  final String? supabaseUrl = dotenv.env['SUPABASE_URL'];
  final String? supabaseKey = dotenv.env['SUPABASE_KEY'] ?? 'KEY_MISSING';
  final String? tableName = dotenv.env['SUPABASE_TABLE_NAME'];

  Future<List<Map<String, dynamic>>> fetchList() async {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/$tableName?select=*'),
      headers: {'apikey': supabaseKey!},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch shopping list');
    }
  }

  Future<void> addItem(Map<String, dynamic> item) async {
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/$tableName'),
      headers: {
        'apikey': supabaseKey!,
        'Authorization': 'Bearer $supabaseKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal',
      },
      body: json.encode(item),
    );

    // print('URL: $supabaseUrl - key: $supabaseKey - table: $tableName');
    // print(json.encode(item));
    // print('Code: ${response.statusCode}');

    if (response.statusCode != 201) {
      throw Exception('Failed to add item to the shopping list');
    }
  }

  Future<void> updateItem(int itemId, Map<String, dynamic> updatedItem) async {
    final response = await http.patch(
      Uri.parse('$supabaseUrl/rest/v1/$tableName?id=eq.$itemId'),
      headers: {
        'apikey': supabaseKey!,
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedItem),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item in the shopping list');
    }
  }

  Future<void> deleteItem(int itemId) async {
    final response = await http.delete(
      Uri.parse('$supabaseUrl/rest/v1/$tableName?id=eq.$itemId'),
      headers: {
        'apikey': supabaseKey!,
        'Authorization': 'Bearer $supabaseKey',
      },
    );

    print('ID: $itemId - Code: ${response.statusCode}');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete item from the shopping list');
    }
  }
}
