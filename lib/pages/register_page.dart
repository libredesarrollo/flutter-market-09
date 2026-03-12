import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tienda_app/pages/login_page.dart';

import 'package:http/http.dart' as http;
import 'package:tienda_app/pages/product/products_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const String ROUTE = "/register";

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isSubmitted = false;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar"),
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
                _usernameTF(),
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
        validator: (val) => !(val?.contains('@') ?? false) ? 'Email inválido' : null,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Email',
          hintText: 'Coloque un email',
          icon: Icon(
            Icons.email,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }

  Widget _usernameTF() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: _usernameController,
        validator: (val) => (val?.length ?? 0) < 3 ? 'Usuario inválido' : null,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Usuario',
          hintText: 'Coloque un usuario',
          icon: Icon(
            Icons.person,
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
                    _registerUser();
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
            Navigator.pushReplacementNamed(context, LoginPage.ROUTE);
          },
          child: const Text("¿Ya tienes cuenta? Inicia sesión"),
        )
      ],
    );
  }

  Widget _title() {
    return Text(
      'Registrar',
      style: Theme.of(context).textTheme.displayLarge,
    );
  }

  Future<void> _registerUser() async {
    setState(() => _isSubmitted = true);

    try {
      final resCart = await http.post(
        Uri.parse('http://10.0.2.2:1337/carts'),
        body: {'products': '[]'},
      );
      final responseDataCart = json.decode(resCart.body);

      final resFavorite = await http.post(
        Uri.parse('http://10.0.2.2:1337/favorites'),
        body: {'products': '[]'},
      );
      final responseDataFavorite = json.decode(resFavorite.body);

      final res = await http.post(
        Uri.parse('http://10.0.2.2:1337/auth/local/register'),
        body: {
          "username": _usernameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "cart_id": responseDataCart['id'].toString(),
          "favorite_id": responseDataFavorite['id'].toString(),
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
      content: Text('Usuario ${_usernameController.text} creado con éxito'),
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
  }

  void _redirectUser() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, ProductsPage.ROUTE);
      }
    });
  }
}

// mongo
// ciX16eQpPsTqDNqb
//@fluttermarket.v1j5x.mongodb.net
