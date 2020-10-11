import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:freibad_app/models/httpException.dart';
import 'package:freibad_app/provider/auth_data.dart';
import 'package:freibad_app/screens/components/custom_textField.dart';
import 'package:provider/provider.dart';

enum AuthMode { Register, Login }

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: AuthCard(),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _passwordController = TextEditingController();
  String errorMessage = 'Could not authenticate you. Please try again later';
  AuthMode _authMode = AuthMode.Login;
  bool _isLoading = false;
  AnimationController _controller;
  Animation<Size> _heightAnimation;

  String name = '';
  String password = '';

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _heightAnimation = Tween<Size>(
            begin: Size(double.infinity, 320), end: Size(double.infinity, 400))
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    //_heightAnimation.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Register;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("An Error Occured"),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text("Okay"))
        ],
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<AuthData>(context, listen: false).login(
            name: name,
            password: password); //setting the token causes a rebuild
      } else {
        if (await Provider.of<AuthData>(context, listen: false)
            .register(name, password)) {
          //login after successful registration
          await Provider.of<AuthData>(context, listen: false)
              .login(name: name, password: password);
        } else {
          throw HttpException('could not register');
        }
      }
    } on HttpException catch (exception) {
      if (exception.toString().isNotEmpty) errorMessage = exception.toString();
      _showErrorDialog(errorMessage);
    } catch (exception) {
      developer.log('Unexpected error for the auth screen: ', error: exception);
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: AnimatedBuilder(
        animation: _heightAnimation,
        builder: (ctx, child) => Container(
          height: _heightAnimation.value.height,
          constraints: BoxConstraints(minHeight: _heightAnimation.value.height),
          width: 300,
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: _heightAnimation.value.height - 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomTextField(
                      labelText: 'Name',
                      validator: (String input) {
                        if (input.isEmpty || input.split(' ').length > 1)
                          return 'Name must be one word';
                        return null;
                      },
                      onSaved: (String value) {
                        name = value;
                      },
                      keyboardType: TextInputType.name,
                    ),
                    CustomTextField(
                      labelText: 'Password',
                      controller: _passwordController,
                      validator: (value) {
                        if (value.isEmpty || value.length < 6) {
                          return 'Password is too short!';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        password = value;
                      },
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                    ),
                    if (_authMode == AuthMode.Register)
                      CustomTextField(
                        labelText: 'Confirm Password',
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        validator: _authMode == AuthMode.Register
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                                return null;
                              }
                            : null,
                      ),
                    SizedBox(height: 15),
                    RaisedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: Text(
                        '${_authMode == AuthMode.Register ? 'REGISTER' : 'LOGIN'}',
                        style: TextStyle(color: Theme.of(context).cardColor),
                      ),
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    FlatButton(
                      onPressed: _switchAuthMode,
                      child: Text(
                        '${_authMode == AuthMode.Register ? 'LOGIN' : 'REGISTER'} INSTEAD',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
