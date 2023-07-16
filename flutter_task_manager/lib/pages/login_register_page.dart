import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? errorMessage = '';
  bool isLogin = true;
  bool isLoading = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controlPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      try {
        await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controlPassword.text,
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message;
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      try {
        await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controlPassword.text,
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message ?? '';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _title() {
    return const Text('Firebase Auth');
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
    String? Function(String?)? validator,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
        errorText: errorMessage == '' ? null : errorMessage,
      ),
      validator: validator,
      onChanged: (_) {
        setState(() {
          errorMessage = '';
        });
      },
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Hum ? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : (isLogin
              ? signInWithEmailAndPassword
              : createUserWithEmailAndPassword),
      child: isLoading
          ? CircularProgressIndicator()
          : Text(isLogin ? 'Login' : 'Register'),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(isLogin ? 'Register Instead' : 'Login Instead'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _entryField(
                'email',
                _controllerEmail,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              _entryField(
                'password',
                _controlPassword,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              _errorMessage(),
              _submitButton(),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }
}
