import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final String baseUrl = 'http://localhost:300'; // Define your base URL here
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLogin = true;
  bool _passwordsMatch = true;

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _passwordsMatch = false);
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      body: json.encode({
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      // Store user ID
      final userId = json.decode(response.body)['id'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId.toString());
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLogin &&
        _passwordController.text != _confirmPasswordController.text) {
      setState(() => _passwordsMatch = false);
      return;
    }

    try {
      if (_isLogin) {
        final success = await ApiService.loginUser(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (success) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          throw Exception('Invalid email or password');
        }
      } else {
        await ApiService.registerUser(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registration successful! Please login')),
        );
        setState(() => _isLogin = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // The overall scaffold remains unchanged.
        body: Column(
      children: [
        Container(
            margin: EdgeInsets.all(25),
            child: Text(
              "Men's Fashion",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            )),
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(bottom: 16),
                          child: Text(
                            _isLogin ? 'Login' : 'Sign Up',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (!_isLogin)
                          TextFormField(
                            controller: _usernameController,
                            validator: (value) =>
                                value!.isEmpty ? 'Enter username' : null,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                            ),
                          ),
                        if (!_isLogin) SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter email' : null,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter password' : null,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                          ),
                        ),
                        SizedBox(height: 16),
                        if (!_isLogin)
                          TextFormField(
                            controller: _confirmPasswordController,
                            validator: (value) =>
                                value!.isEmpty ? 'Confirm password' : null,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              errorText: _passwordsMatch
                                  ? null
                                  : 'Passwords do not match',
                            ),
                          ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _isLogin ? 'Login' : 'Sign Up',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(
                            _isLogin
                                ? 'Create new account'
                                : 'I already have an account',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
