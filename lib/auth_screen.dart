import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restful_api/auth_provider.dart';

enum AuthMode { SignUp, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Header Title My Shop
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Text(
                        'MyShop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                        ),
                      ),
                    ),
                  ),
                  // Form
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      /// Log user in
      if (_authMode == AuthMode.Login) {
        await Provider.of<AuthProvider>(context, listen: false).logIn(
          _authData['email']!,
          _authData['password']!,
        );
        //Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyHomePage()));
      } else {
        /// Sign user up
        await Provider.of<AuthProvider>(context, listen: false).signUp(
          _authData['email']!,
          _authData['password']!,
        );
        //Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyHomePage()));
      }

      /// error receiving from _authenticate Fun throw error
    } catch (error) {
      String errorMessage = 'Authentication Failed!';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage =
            'The email address is already in use by another account.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('OPERATION_NOT_ALLOWED')) {
        errorMessage = 'Password sign-in is disabled for this project.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage =
            ' There is no user record corresponding to this identifier. The user may have been deleted.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage =
            'The password is invalid or the user does not have a password.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is to weak';
      }
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('An Error Ocure'),
                content: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ));
    } // catch
    setState(() {
      _isLoading = false;
    });
  }

  //
  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.SignUp ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.SignUp ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),
                if (_authMode == AuthMode.SignUp)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    height: _authMode == AuthMode.SignUp ? 65 : 0,
                    constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.SignUp ? 65 : 0),
                    child: TextFormField(
                      enabled: _authMode == AuthMode.SignUp,
                      decoration:
                          const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: _authMode == AuthMode.SignUp
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match!';
                              }
                              return null;
                            }
                          : null,
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor),
                      //foregroundColor: MaterialStateProperty.all(Colors.orange),
                    ),
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                  ),
                TextButton(
                  onPressed: _switchAuthMode,
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGN UP' : 'LOGIN'} INSTEAD'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
