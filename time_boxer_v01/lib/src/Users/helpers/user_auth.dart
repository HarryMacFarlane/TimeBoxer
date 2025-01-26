import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserAuthenticator {

  final FirebaseAuth _instance = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool check_active_user() {
    try {
      final User? user = _instance.currentUser;
      if (user != null) {
        return true;
      }
      return false;
    } catch (e) {
      print('User Authenticator encountered error checking active user: $e');
      return false;
    }
  }

  Future<UserCredential?> basic_create_user({required String email,required String password,}) async {
    try {
      print(email);
      print(password);
      
      final UserCredential userCredential = await _instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ADD CODE TO CHECK IF USER ALREADY EXISTS

      // ADD CODE TO CREATE USER DOCUMENT

      // Handle user signup success
      print('User Authenticator successfully signed up: ${userCredential.user?.email}');

      // return userCredential;
      return userCredential;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> basic_sign_in({required String email,required String password,}) async {
    try{
        final UserCredential userCreds = await _instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // CODE TO CHECK IF USER EXISTS

        // CODE TO CHECK IF USER HAS LISTENER ATTACHED
        return userCreds;
    }
    catch(e){
      print('User Authenticator could not execute basic_sign_in: $e');
      rethrow;
    }
  }

  Future<UserCredential?> google_sign_in() async{
    try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        print('UserAuthenticator successfully obtained Google credentials: $credential');

        final UserCredential userCredential = await _instance.signInWithCredential(credential);

        print('UserAuthenticator successfully signed in with Google: ${userCredential.user?.email}');

        return userCredential;
      } 
      catch (e) {
        print('User Authenticator encountered error using google_sign_in: $e');
    }
  }
}