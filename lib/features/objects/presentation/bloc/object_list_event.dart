import 'package:equatable/equatable.dart';

abstract class ObjectListEvent extends Equatable {
  const ObjectListEvent();

  @override
  List<Object?> get props => [];
}

class LoadObjects extends ObjectListEvent {
  const LoadObjects();
}

class RefreshObjects extends ObjectListEvent {
  const RefreshObjects();
}

class SearchObjects extends ObjectListEvent {
  final String query;
  const SearchObjects(this.query);

  @override
  List<Object?> get props => [query];
}

class DeleteObjectFromList extends ObjectListEvent {
  final String id;
  const DeleteObjectFromList(this.id);

  @override
  List<Object?> get props => [id];
}

class AddObjectToList extends ObjectListEvent {
  final String id;
  final String name;
  final Map<String, dynamic>? data;
  const AddObjectToList({required this.id, required this.name, this.data});

  @override
  List<Object?> get props => [id, name, data];
}
