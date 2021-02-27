import 'package:flutter/material.dart';
import 'package:market/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  static const String ROUTE = "/login";

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
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
              Navigator.pushReplacementNamed(context, RegisterPage.ROUTE);
            },
            child: Text("¿Tienes una cuenta?"))
      ],
    );
  }

  Widget _title() {
    return Text(
      'Login',
      style: Theme.of(context).textTheme.headline1,
    );
  }
}
