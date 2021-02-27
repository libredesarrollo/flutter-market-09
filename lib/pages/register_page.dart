import 'package:flutter/material.dart';
import 'package:market/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  static const String ROUTE = "/register";

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        validator: (val) => val.length > 5 ? 'Usuario inválido' : null,
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
        RaisedButton(
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
}
