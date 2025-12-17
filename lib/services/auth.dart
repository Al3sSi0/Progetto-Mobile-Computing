import 'package:firebase_auth/firebase_auth.dart';

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

}
