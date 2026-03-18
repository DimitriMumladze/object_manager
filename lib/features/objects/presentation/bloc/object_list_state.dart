import 'package:equatable/equatable.dart';
import '../../data/models/api_object_model.dart';

abstract class ObjectListState extends Equatable {
  const ObjectListState();

  @override
  List<Object?> get props => [];
}

class ObjectListInitial extends ObjectListState {
  const ObjectListInitial();
}

class ObjectListLoading extends ObjectListState {
  const ObjectListLoading();
}

class ObjectListLoaded extends ObjectListState {
  final List<ApiObject> objects;
  final List<ApiObject> filteredObjects;
  final String searchQuery;

  const ObjectListLoaded({
    required this.objects,
    required this.filteredObjects,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [objects, filteredObjects, searchQuery];
}

class ObjectListError extends ObjectListState {
  final String message;

  const ObjectListError(this.message);

  @override
  List<Object?> get props => [message];
}
