import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000'; // Android emulator
  static Map<String, dynamic> currentUser = {};

  //================= Authentication =================//
  static Future<void> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'image': '',
        'cart': []
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', responseData['id'].toString());
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  static Future<bool> loginUser(String email, String password) async {
    final response = await http.get(Uri.parse('$baseUrl/users?email=$email'));

    if (response.statusCode == 200) {
      final List<dynamic> users = json.decode(response.body);
      if (users.isNotEmpty && users[0]['password'] == password) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', users[0]['id'].toString());
        currentUser = users[0];
        return true;
      }
    }
    return false;
  }

  //================= Product Management =================//
  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to load products');
  }

  //================= User Profile Management =================//
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) throw Exception('User not logged in');

    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      currentUser = json.decode(response.body);
      return currentUser;
    }
    throw Exception('Failed to load user data');
  }

  static Future<bool> updateUsername(String newUsername) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': newUsername}),
    );

    return response.statusCode == 200;
  }

  static Future<bool> changePassword(
      String oldPassword, String newPassword) async {
    final user = await getCurrentUser();
    if (user['password'] != oldPassword) {
      print("Current password is incorrect");
      return false;
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/users/${user['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'password': newPassword}),
    );

    return response.statusCode == 200;
  }

  static Future<void> uploadProfileImage(File image) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'image': 'data:image/jpeg;base64,$base64Image'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Image upload failed');
    }
  }

  //================= Cart Management =================//
  static Future<void> syncCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'cart': items
            .map((item) => {
                  'productId': item.product.id,
                  'size': item.size,
                  'quantity': item.quantity
                })
            .toList()
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Cart sync failed');
    }
  }

  //================= Account Management =================//
  static Future<bool> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final response = await http.delete(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      await prefs.clear();
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    currentUser = {};
  }

  static checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') != null;
  }
}

class CartItem {
  final Product product;
  String size;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.quantity,
  });
}
