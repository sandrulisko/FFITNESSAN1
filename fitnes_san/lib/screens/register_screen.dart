import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false; 

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rejestracja')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Hasło'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                setState(() {
                  _isLoading = true;
                });
                try {
                  var user = await _auth.registerWithEmail(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                  if (user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Rejestracja nieudana. Spróbuj ponownie')),
                    );
                  }
                } catch (e) {
                  if (e is FirebaseAuthException) {
                    if (e.code == 'weak-password') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hasło jest za słabe.')),
                      );
                    } else if (e.code == 'email-already-in-use') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Email już w użyciu.')),
                      );
                    }
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pojawił się błąd. Spróbuj ponownie.')),
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: _isLoading ? CircularProgressIndicator() : Text('Zarejestruj się'),
            ),
          ],
        ),
      ),
    );
  }
}
