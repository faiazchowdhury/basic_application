import 'package:basic_application/bloc/Bloc/allcalls_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AllPagesAppBar {
  static PreferredSizeWidget? appBar(BuildContext context, String text) {
    final bloc = new AllcallsBloc();
    return AppBar(
      actions: [
        GestureDetector(
          onTap: () async {
            bloc.add(logout(context));
          },
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.all(20),
            child: Align(alignment: Alignment.topRight, child: Text("Log Out")),
          ),
        ),
      ],
      title: Text(text),
      backgroundColor: Color.fromRGBO(13, 106, 106, 1),
      elevation: 0,
    );
  }
}
