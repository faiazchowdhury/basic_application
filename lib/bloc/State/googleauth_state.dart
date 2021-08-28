part of '../Bloc/googleauth_bloc.dart';

abstract class GoogleauthState extends Equatable {
  const GoogleauthState();

  @override
  List<Object> get props => [];
}

class GoogleauthInitial extends GoogleauthState {}

class GoogleauthLoading extends GoogleauthState {}

class GoogleauthLoadedWithResponse extends GoogleauthState {
  final response;
  GoogleauthLoadedWithResponse(this.response);
}
