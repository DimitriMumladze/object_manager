import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/api_object_model.dart';
import '../../data/repositories/object_repository.dart';
import 'object_list_event.dart';
import 'object_list_state.dart';

class ObjectListBloc extends Bloc<ObjectListEvent, ObjectListState> {
  final ObjectRepository _repository;

  ObjectListBloc({required ObjectRepository repository})
      : _repository = repository,
        super(const ObjectListInitial()) {
    on<LoadObjects>(_onLoadObjects);
    on<RefreshObjects>(_onRefreshObjects);
    on<SearchObjects>(_onSearchObjects);
    on<DeleteObjectFromList>(_onDeleteObject);
    on<AddObjectToList>(_onAddObject);
  }

  Future<void> _onLoadObjects(
    LoadObjects event,
    Emitter<ObjectListState> emit,
  ) async {
    emit(const ObjectListLoading());
    try {
      final objects = await _repository.getObjects();
      emit(ObjectListLoaded(objects: objects, filteredObjects: objects));
    } catch (e) {
      emit(ObjectListError(_parseError(e)));
    }
  }

  Future<void> _onRefreshObjects(
    RefreshObjects event,
    Emitter<ObjectListState> emit,
  ) async {
    try {
      final objects = await _repository.getObjects();
      final query = state is ObjectListLoaded
          ? (state as ObjectListLoaded).searchQuery
          : '';
      final filtered = _filterObjects(objects, query);
      emit(ObjectListLoaded(
        objects: objects,
        filteredObjects: filtered,
        searchQuery: query,
      ));
    } catch (e) {
      emit(ObjectListError(_parseError(e)));
    }
  }

  void _onSearchObjects(
    SearchObjects event,
    Emitter<ObjectListState> emit,
  ) {
    if (state is ObjectListLoaded) {
      final currentState = state as ObjectListLoaded;
      final filtered = _filterObjects(currentState.objects, event.query);
      emit(ObjectListLoaded(
        objects: currentState.objects,
        filteredObjects: filtered,
        searchQuery: event.query,
      ));
    }
  }

  Future<void> _onDeleteObject(
    DeleteObjectFromList event,
    Emitter<ObjectListState> emit,
  ) async {
    if (state is ObjectListLoaded) {
      final currentState = state as ObjectListLoaded;
      try {
        await _repository.deleteObject(event.id);
        final updated = currentState.objects
            .where((obj) => obj.id != event.id)
            .toList();
        final filtered = _filterObjects(updated, currentState.searchQuery);
        emit(ObjectListLoaded(
          objects: updated,
          filteredObjects: filtered,
          searchQuery: currentState.searchQuery,
        ));
      } catch (e) {
        emit(ObjectListLoaded(
          objects: currentState.objects,
          filteredObjects: currentState.filteredObjects,
          searchQuery: currentState.searchQuery,
        ));
        rethrow;
      }
    }
  }

  void _onAddObject(
    AddObjectToList event,
    Emitter<ObjectListState> emit,
  ) {
    final newObject = ApiObject(
      id: event.id,
      name: event.name,
      data: event.data,
    );
    if (state is ObjectListLoaded) {
      final currentState = state as ObjectListLoaded;
      final updated = [newObject, ...currentState.objects];
      final filtered = _filterObjects(updated, currentState.searchQuery);
      emit(ObjectListLoaded(
        objects: updated,
        filteredObjects: filtered,
        searchQuery: currentState.searchQuery,
      ));
    } else {
      emit(ObjectListLoaded(objects: [newObject], filteredObjects: [newObject]));
    }
  }

  List<ApiObject> _filterObjects(List<ApiObject> objects, String query) {
    if (query.isEmpty) return objects;
    final lower = query.toLowerCase();
    return objects.where((obj) {
      return obj.name.toLowerCase().contains(lower) ||
          obj.id.toLowerCase().contains(lower);
    }).toList();
  }

  String _parseError(dynamic error) {
    return "Couldn't load objects. Check your connection and try again.";
  }
}
