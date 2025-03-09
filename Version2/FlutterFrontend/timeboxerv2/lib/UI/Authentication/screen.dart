import 'package:flutter/material.dart';
import 'package:timeboxerv2/Providers/master_provider.dart';
import 'package:timeboxerv2/Providers/user_provider.dart';
import 'form.dart';

class AuthScreen extends StatefulWidget {
  final Function(UserProvider) onLogin;

  const AuthScreen({Key? key, required this.onLogin}) : super(key:key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _authenticate(String email, String password, bool isLogin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      
      UserProvider userProvider;
      if (isLogin){
       userProvider = await MasterProvider.login(email, password, password);
      }
      else {
        userProvider = await MasterProvider.signUp(email, password, password);
      }

      widget.onLogin(userProvider);

      // ADD SOME BETTER ERROR MESSAGES BASED ON RESPONSE CODE! (see the error!)
    } catch (error) {
      String message;
      if (isLogin) {
        message = "Either your email or password is incorrect! Try again , or register to create an account!";
      }
      else {
        message  = "Something went wrong during your registration! Please try again.";
      }
      setState(() {
        _errorMessage = message;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Auth Page')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_errorMessage != null)
                    Text(_errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 16)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AuthForm(onSubmit: _authenticate),
                  ),
                ],
              ),
      ),
    );
  }
}
