import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:market/pages/login_page.dart';

import 'package:http/http.dart' as http;
import 'package:market/pages/product/products_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  static const String ROUTE = "/register";

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _obscurePassword = true;

  bool isSubmitted = false;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Registrar"),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          margin: EdgeInsets.all(8),
          child: Column(
            children: [
              _title(),
              SizedBox(
                height: 15,
              ),
              _usernameTF(),
              _emailTF(),
              _passwordTF(),
              _actions()
            ],
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
        validator: (val) => !val.contains('@') ? 'Email inválida' : null,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Email',
            hintText: 'Coloque un email',
            icon: Icon(
              Icons.email,
              color: Theme.of(context).accentColor,
            )),
      ),
    );
  }

  Widget _usernameTF() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: _usernameController,
        validator: (val) => val.length < 3 ? 'Usuario inválido' : null,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Usuario',
            hintText: 'Coloque un usuario',
            icon: Icon(
              Icons.person,
              color: Theme.of(context).accentColor,
            )),
      ),
    );
  }

  Widget _passwordTF() {
    return TextFormField(
      obscureText: _obscurePassword,
      controller: _passwordController,
      validator: (val) => val.length < 5 ? 'Contraseña inválida' : null,
      decoration: InputDecoration(
          suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              child: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off)),
          border: OutlineInputBorder(),
          labelText: 'Password',
          hintText: 'Coloque un password',
          icon: Icon(
            Icons.lock,
            color: Theme.of(context).accentColor,
          )),
    );
  }

  Widget _actions() {
    return Column(
      children: [
        isSubmitted
            ? CircularProgressIndicator()
            : RaisedButton(
                splashColor: Theme.of(context).primaryColorDark,
                color: Theme.of(context).primaryColor,
                child: Text("Enviar",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.white)),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    print("Formulario válido!");
                    _registerUser();
                  } else {
                    print("errores en el form");
                  }
                }),
        FlatButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, LoginPage.ROUTE);
            },
            child: Text("Iniciar sesión"))
      ],
    );
  }

  Widget _title() {
    return Text(
      'Registrar',
      style: Theme.of(context).textTheme.headline1,
    );
  }

  void _registerUser() async {
    setState(() => isSubmitted = true);

    final res =
        await http.post('http://10.0.2.2:1337/auth/local/register', body: {
      "username": _usernameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
    });

    setState(() => isSubmitted = false);

    final responseData = json.decode(res.body);
    if (res.statusCode == 200) {
      print("Respuesta correcta");
      _successResponse();
      _storeUserData(responseData);
      _redirectUser();
    } else {
      _errorResponse(responseData['message'][0]['messages'][0]['message']);
    }
  }

  void _successResponse() {
    final _snackBar = SnackBar(
        content: Text(
      'Usuario ${_usernameController.text} creado con éxito',
      style: TextStyle(color: Theme.of(context).accentColor),
    ));
    // Scaffold.of(context).showSnackBar(_snackBar);
    _scaffoldKey.currentState.showSnackBar(_snackBar);
  }

  void _errorResponse(String msj) {
    final _snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          msj,
          style: TextStyle(color: Colors.white),
        ));
    // Scaffold.of(context).showSnackBar(_snackBar);
    _scaffoldKey.currentState.showSnackBar(_snackBar);
  }

  void _storeUserData(Map<String, dynamic> responseData) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('jwt', responseData['jwt']);
    prefs.setString('email', responseData['user']['email']);
    prefs.setString('username', responseData['user']['username']);
    prefs.setString('id', responseData['user']['_id']);

    print(prefs.getString('jwt'));
    print(prefs.getString('email'));
    print(prefs.getString('username'));
    print(prefs.getString('id'));
  }

  void _redirectUser() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, ProductsPage.ROUTE);
    });
  }
}

// mongo
// ciX16eQpPsTqDNqb
//@fluttermarket.v1j5x.mongodb.net
