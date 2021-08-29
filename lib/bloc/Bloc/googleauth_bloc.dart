import 'dart:async';

import 'package:basic_application/Model/UserInfoStore.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

part '../Event/googleauth_event.dart';
part '../State/googleauth_state.dart';

class GoogleauthBloc extends Bloc<GoogleauthEvent, GoogleauthState> {
  GoogleauthBloc() : super(GoogleauthInitial());

  @override
  Stream<GoogleauthState> mapEventToState(
    GoogleauthEvent event,
  ) async* {
    if (event is InitializeFirebase) {
      yield GoogleauthLoading();
      FirebaseApp firebaseApp = await Firebase.initializeApp();
      User? user = FirebaseAuth.instance.currentUser;
      UserInfoStore.setUser = user;
      yield GoogleauthLoadedWithResponse(user);
    }

    if (event is signInWithGoogle) {
      yield GoogleauthLoading();
      FirebaseAuth auth = FirebaseAuth.instance;
      late User user;

      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount googleSignInAccount =
          (await googleSignIn.signIn())!;

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);

          user = userCredential.user!;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            // handle the error here
          } else if (e.code == 'invalid-credential') {
            // handle the error here
          }
        } catch (e) {
          // handle the error here
        }
      }
      UserInfoStore.setUser = user;

      yield GoogleauthLoadedWithResponse(user);
    }
  }
}
