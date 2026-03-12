import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tienda_app/pages/register_page.dart';

import 'package:http/http.dart' as http;
import 'package:tienda_app/pages/product/products_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String ROUTE = "/login";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isSubmitted = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          margin: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _title(),
                const SizedBox(height: 15),
                _emailTF(),
                _passwordTF(),
                _actions()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailTF() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: _emailController,
        validator: (val) => (val?.length ?? 0) < 3 ? 'Cuenta inválida' : null,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Email o usuario',
          hintText: 'Coloque un email o usuario',
          icon: Icon(
            Icons.email,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }

  Widget _passwordTF() {
    return TextFormField(
      obscureText: _obscurePassword,
      controller: _passwordController,
      validator: (val) => (val?.length ?? 0) < 5 ? 'Contraseña inválida' : null,
      decoration: InputDecoration(
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          child: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
        ),
        border: const OutlineInputBorder(),
        labelText: 'Password',
        hintText: 'Coloque un password',
        icon: Icon(
          Icons.lock,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _actions() {
    final theme = Theme.of(context);
    return Column(
      children: [
        _isSubmitted
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _loginUser();
                  }
                },
                child: Text(
                  "Enviar",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, RegisterPage.ROUTE);
          },
          child: const Text("¿No tienes cuenta? Regístrate"),
        )
      ],
    );
  }

  Widget _title() {
    return Text(
      'Login',
      style: Theme.of(context).textTheme.displayLarge,
    );
  }

  Future<void> _loginUser() async {
    setState(() => _isSubmitted = true);

    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2:1337/auth/local'),
        body: {
          "identifier": _emailController.text,
          "password": _passwordController.text,
        },
      );

      if (!mounted) return;
      setState(() => _isSubmitted = false);

      final responseData = json.decode(res.body);
      if (res.statusCode == 200) {
        _successResponse();
        await _storeUserData(responseData);
        if (!mounted) return;
        _redirectUser();
      } else {
        _errorResponse(responseData['message'][0]['messages'][0]['message']);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitted = false);
      _errorResponse("Error connecting to server");
    }
  }

  void _successResponse() {
    final snackBar = SnackBar(
      content: Text('Login correcto para ${_emailController.text}'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _errorResponse(String msj) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        msj,
        style: const TextStyle(color: Colors.white),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _storeUserData(Map<String, dynamic> responseData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', responseData['jwt']);
    await prefs.setString('email', responseData['user']['email']);
    await prefs.setString('username', responseData['user']['username']);
    await prefs.setString('id', responseData['user']['_id']);
    await prefs.setString('cart_id', responseData['user']['cart_id']);
    await prefs.setString('favorite_id', responseData['user']['favorite_id']);
  }

  void _redirectUser() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, ProductsPage.ROUTE);
      }
    });
  }
}
