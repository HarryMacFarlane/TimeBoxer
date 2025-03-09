import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(String email, String password, bool isLogin) onSubmit;

  const AuthForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true; // Toggle between login and register

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_emailController.text, _passwordController.text, _isLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value!.isEmpty ? 'Please enter your email' : null,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) =>
                value!.isEmpty ? 'Please enter your password' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            child: Text(_isLogin ? 'Sign In' : 'Register'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isLogin = !_isLogin; // Toggle form mode
              });
            },
            child: Text(_isLogin
                ? "Don't have an account? Register"
                : "Already have an account? Sign In"),
          ),
        ],
      ),
    );
  }
}
