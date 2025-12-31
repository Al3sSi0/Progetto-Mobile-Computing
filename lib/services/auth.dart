import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:corner/authenticate/authentication.dart';

class AuthService {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signEmailPass({required String email, required String password}) async{
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createEmailPass({required String email, required String password}) async{
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future signOut() async{
    await _auth.signOut();
  }

  Future anon() async{
     await _auth.signInAnonymously();
  }

Future<UserCredential?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) return null; 
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
    
  } catch (e) {
    print("Errore durante il login Google: $e");
    return null;
  }
}

}
