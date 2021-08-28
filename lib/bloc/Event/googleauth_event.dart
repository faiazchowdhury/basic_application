part of '../Bloc/googleauth_bloc.dart';

abstract class GoogleauthEvent extends Equatable {
  const GoogleauthEvent();

  @override
  List<Object> get props => [];
}

class InitializeFirebase extends GoogleauthEvent {}

class signInWithGoogle extends GoogleauthEvent {}
