import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../config/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _answerController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  String? _securityQuestion;
  bool _isLoading = false;
  int _step = 1; // 1: Email, 2: Security Question, 3: New Password

  @override
  void dispose() {
    _emailController.dispose();
    _answerController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _getSecurityQuestion() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _authService.getSecurityQuestion(_emailController.text);
      setState(() {
        _securityQuestion = response['securityQuestion'];
        _step = 2;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(
        _emailController.text,
        _answerController.text,
        _passwordController.text,
      );
      
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              _step == 1 ? 'Enter Your Email' : 
              _step == 2 ? 'Security Question' : 'Reset Password',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            if (_step == 1) ...[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _getSecurityQuestion,
                child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('Continue'),
              ),
            ],
            
            if (_step == 2) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _securityQuestion ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _answerController,
                decoration: const InputDecoration(
                  labelText: 'Your Answer',
                  prefixIcon: Icon(Icons.key),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('Reset Password'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}