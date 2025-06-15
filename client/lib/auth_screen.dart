import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'profile_screen.dart';
import 'TokenStorage.dart'; // не забудь импортировать твой класс

class AuthScreen extends StatefulWidget {
  final Future<void> Function()? onRefreshCart;

  const AuthScreen({super.key, this.onRefreshCart});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showLogin = true;
  bool _isAuthenticated = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final loggedIn = await TokenStorage.isLoggedIn();

    setState(() {
      _isAuthenticated = loggedIn;
      _loading = false;
    });
  }

  void _toggleForm() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  Future<void> _onLoginSuccess() async {
    setState(() {
      _isAuthenticated = true;
    });

    if (widget.onRefreshCart != null) {
      await widget.onRefreshCart!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isAuthenticated) {
      return const ProfileScreen();
    }

    return _showLogin
        ? LoginScreen(
            onToggle: _toggleForm,
            onLoginSuccess: _onLoginSuccess,
          )
        : RegisterScreen(onToggle: _toggleForm);
  }
}
