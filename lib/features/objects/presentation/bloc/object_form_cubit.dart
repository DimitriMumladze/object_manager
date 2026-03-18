import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/api_object_model.dart';
import '../../data/repositories/object_repository.dart';

abstract class ObjectFormState extends Equatable {
  const ObjectFormState();
  @override
  List<Object?> get props => [];
}

class ObjectFormInitial extends ObjectFormState {
  const ObjectFormInitial();
}

class ObjectFormSaving extends ObjectFormState {
  const ObjectFormSaving();
}

class ObjectFormSuccess extends ObjectFormState {
  final ApiObject object;
  const ObjectFormSuccess(this.object);
  @override
  List<Object?> get props => [object];
}

class ObjectFormError extends ObjectFormState {
  final String message;
  const ObjectFormError(this.message);
  @override
  List<Object?> get props => [message];
}

class ObjectFormCubit extends Cubit<ObjectFormState> {
  final ObjectRepository _repository;

  ObjectFormCubit({required ObjectRepository repository})
      : _repository = repository,
        super(const ObjectFormInitial());

  Future<void> createObject({
    required String name,
    Map<String, dynamic>? data,
  }) async {
    emit(const ObjectFormSaving());
    try {
      final object = await _repository.createObject(name: name, data: data);
      emit(ObjectFormSuccess(object));
    } catch (e) {
      emit(ObjectFormError(_parseError(e, 'create')));
    }
  }

  Future<void> updateObject({
    required String id,
    required String name,
    Map<String, dynamic>? data,
  }) async {
    emit(const ObjectFormSaving());
    try {
      final object = await _repository.updateObject(
        id: id,
        name: name,
        data: data,
      );
      emit(ObjectFormSuccess(object));
    } catch (e) {
      emit(ObjectFormError(_parseError(e, 'update')));
    }
  }

  Future<void> patchObject({
    required String id,
    String? name,
    Map<String, dynamic>? data,
  }) async {
    emit(const ObjectFormSaving());
    try {
      final object = await _repository.patchObject(
        id: id,
        name: name,
        data: data,
      );
      emit(ObjectFormSuccess(object));
    } catch (e) {
      emit(ObjectFormError(_parseError(e, 'update')));
    }
  }

  String _parseError(dynamic error, String action) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 405) {
        return 'Cannot $action this object. Pre-defined objects (IDs 1-13) '
            'are read-only. Create your own object first, or use authenticated '
            'mode via API Settings.';
      }
      if (statusCode == 401) {
        return 'Unauthorized. Check your API key in Settings.';
      }
      if (statusCode == 403) {
        return 'Forbidden. You don\'t have permission to $action this object.';
      }
      if (statusCode == 404) {
        return 'Object not found. It may have been deleted.';
      }
    }
    return 'Failed to $action object. Check your connection and try again.';
  }

  void reset() {
    emit(const ObjectFormInitial());
  }
}
