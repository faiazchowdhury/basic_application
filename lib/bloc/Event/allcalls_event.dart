part of '../Bloc/allcalls_bloc.dart';

abstract class AllcallsEvent extends Equatable {
  const AllcallsEvent();

  @override
  List<Object> get props => [];
}

class getAutoCompleteResponse extends AllcallsEvent {
  final String pattern;
  getAutoCompleteResponse(this.pattern);
}

class getCurrentLocation extends AllcallsEvent {}

class measureDistance extends AllcallsEvent {
  final String name;

  measureDistance(this.name);
}

class postDistance extends AllcallsEvent {
  final String current_place, searched_place, distance;
  postDistance(this.current_place, this.searched_place, this.distance);
}

class getListOfHistory extends AllcallsEvent {}

class removeEntry extends AllcallsEvent {
  final String docId;

  removeEntry(this.docId);
}

class logout extends AllcallsEvent {
  final BuildContext context;
  logout(this.context);
}
