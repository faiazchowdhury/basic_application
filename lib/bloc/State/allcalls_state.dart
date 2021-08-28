part of '../Bloc/allcalls_bloc.dart';

abstract class AllcallsState extends Equatable {
  const AllcallsState();

  @override
  List<Object> get props => [];
}

class AllcallsInitial extends AllcallsState {}

class AllcallsLoading extends AllcallsState {}

class AllcallsLoadedWithResponse extends AllcallsState {
  final response;
  AllcallsLoadedWithResponse(this.response);
}
