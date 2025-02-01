import 'dart:io';
import 'dart:typed_data';

import 'package:clothing/services/api_service.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _usernameController;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // For mobile: store a File, for web: store the image bytes.
  File? _profileImage;
  Uint8List? _profileImageBytes;

  bool _isEditingUsername = false;
  bool _isChangingPassword = false;
  bool _passwordsMatch = true;
  bool _isLoading = true; // loading state

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(); // Initialize here
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await ApiService.getCurrentUser();
      _usernameController.text = user['username']; // Set initial value
      setState(() => _isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Reduce quality if needed
        maxWidth: 800, // Limit resolution
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // For web, read as bytes
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _profileImageBytes = bytes;
          });
          print('Image selected (web) with ${bytes.length} bytes.');
        } else {
          // For mobile, use the file path
          final File imageFile = File(pickedFile.path);
          if (await imageFile.exists()) {
            setState(() {
              _profileImage = imageFile;
            });
            print('Image path: ${imageFile.path}');
          } else {
            print('Selected file does not exist');
          }
        }
      }
    } catch (e) {
      print('Image picker error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _updateUsername() async {
    if (await ApiService.updateUsername(_usernameController.text)) {
      setState(() => _isEditingUsername = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _passwordsMatch = false);
      return;
    }

    if (await ApiService.changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    )) {
      setState(() {
        _isChangingPassword = false;
        _passwordsMatch = true;
      });
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You current password is invalid.')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    if (await ApiService.deleteAccount()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 91, 134, 236),
        elevation: 2,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image Section
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.deepPurpleAccent.withOpacity(0.2),
                backgroundImage: kIsWeb && _profileImageBytes != null
                    ? MemoryImage(_profileImageBytes!)
                    : _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                child: (_profileImage == null && _profileImageBytes == null)
                    ? Icon(Icons.camera_alt,
                        size: 40, color: Colors.deepPurpleAccent)
                    : null,
              ),
            ),
            SizedBox(height: 20),

            // Username TextField
            TextField(
              controller: _usernameController,
              readOnly: !_isEditingUsername,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurpleAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: const Color.fromARGB(255, 91, 134, 236), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isEditingUsername ? Icons.check : Icons.edit,
                    color: Colors.deepPurpleAccent,
                  ),
                  onPressed: () => _isEditingUsername
                      ? _updateUsername()
                      : setState(() => _isEditingUsername = true),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Change Password Section
            if (_isChangingPassword) ...[
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurpleAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color.fromARGB(255, 91, 134, 236),
                        width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurpleAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color.fromARGB(255, 91, 134, 236),
                        width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurpleAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color.fromARGB(255, 91, 134, 236),
                        width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _passwordsMatch ? null : 'Passwords do not match',
                ),
              ),
              SizedBox(height: 10),
              // Side-by-side buttons for update and cancel
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 91, 134, 236),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      onPressed: _changePassword,
                      child: Text(
                        'Update Password',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      onPressed: () =>
                          setState(() => _isChangingPassword = false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              // Button to initiate password change (centered)
              ElevatedButton(
                
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 91, 134, 236),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: () => setState(() => _isChangingPassword = true),
                child: Text(
                  'Change Password',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            SizedBox(height: 20),

            // Delete Account Button
            TextButton(
              onPressed: _deleteAccount,
              child: Text(
                'Delete Account',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
