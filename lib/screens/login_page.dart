import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _agreeToTerms = false;
  String _error = '';

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _handleEmailAuth() async {
    if (!_agreeToTerms) {
      setState(() {
        _error = 'Vui lòng đồng ý với điều khoản và chính sách bảo mật';
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        final email = '${_usernameController.text}@gmail.com';
        if (_isLogin) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: _passwordController.text,
          );
        } else {
          final userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: _passwordController.text,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'email': email,
            'username': _usernameController.text,
            'displayName': 'User${userCredential.user!.uid}',
          });
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _error = _getErrorMessage(e.code);
        });
      }
    }
  }

  Future<void> _handleGoogleAuth() async {
    if (!_agreeToTerms) {
      setState(() {
        _error = 'Vui lòng đồng ý với điều khoản và chính sách bảo mật';
      });
      return;
    }

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Kiểm tra và tạo document user trong Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': userCredential.user!.email,
          'username': userCredential.user!.displayName,
          'displayName': userCredential.user!.displayName,
        });
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      setState(() {
        _error = 'Đã xảy ra lỗi khi đăng nhập với Google';
      });
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Tài khoản không tồn tại';
      case 'wrong-password':
        return 'Sai mật khẩu';
      case 'invalid-email':
        return 'Tài khoản không hợp lệ';
      case 'email-already-in-use':
        return 'Tài khoản đã được sử dụng';
      default:
        return 'Đã xảy ra lỗi trong quá trình xác thực';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? 'Đăng nhập' : 'Đăng ký',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  // Username field
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên đăng nhập',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên đăng nhập';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Confirm Password field - chỉ hiện khi đăng ký
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Xác nhận mật khẩu',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng xác nhận mật khẩu';
                        }
                        if (value != _passwordController.text) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Terms checkbox
                  CheckboxListTile(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    title: const Text('Tôi đồng ý với điều khoản sử dụng'),
                  ),
                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Login/Register button
                  ElevatedButton(
                    onPressed: _handleEmailAuth,
                    child: Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
                  ),
                  const SizedBox(height: 16),
                  // Google sign in button
                  ElevatedButton.icon(
                    onPressed: _handleGoogleAuth,
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text('Đăng nhập với Google'),
                  ),
                  const SizedBox(height: 16),
                  // Switch between login/register
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _error = '';
                      });
                    },
                    child: Text(_isLogin
                        ? 'Chưa có tài khoản? Đăng ký'
                        : 'Đã có tài khoản? Đăng nhập'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
