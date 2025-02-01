// Local Imports
import 'package:time_boxer_v01/src/Backend/helpers/database_connector.dart';

import 'Screens/HomeScreen.dart';
import 'sidebar.dart';
import '../Providers/master_provider.dart';

// Package Imports
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(clientId: dotenv.env['GOOGLE_CLIENT_ID']!),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Welcome to the App'),
                );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to FlutterFire, please sign in!')
                    : const Text('Welcome to Flutterfire, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text('THIS WILL ONLY BE SHOWN ON WEB OR DESKTOP'),
              );
            },
          );
        }

        User? user = FirebaseAuth.instance.currentUser;
        
        assert (user != null); // Should never be null as they just signed in...
        

        MasterProvider.createHolder(user!.uid); // Safe bang used with assert
        
        return SidebarScaffold(body: HomeScreen());
      },
    );
  }
}