import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/api_object_model.dart';
import '../../data/repositories/object_repository.dart';

abstract class ObjectDetailState extends Equatable {
  const ObjectDetailState();
  @override
  List<Object?> get props => [];
}

class ObjectDetailInitial extends ObjectDetailState {
  const ObjectDetailInitial();
}

class ObjectDetailLoading extends ObjectDetailState {
  const ObjectDetailLoading();
}

class ObjectDetailLoaded extends ObjectDetailState {
  final ApiObject object;
  const ObjectDetailLoaded(this.object);
  @override
  List<Object?> get props => [object];
}

class ObjectDetailError extends ObjectDetailState {
  final String message;
  const ObjectDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class ObjectDeleted extends ObjectDetailState {
  const ObjectDeleted();
}

class ObjectDetailCubit extends Cubit<ObjectDetailState> {
  final ObjectRepository _repository;

  ObjectDetailCubit({required ObjectRepository repository})
      : _repository = repository,
        super(const ObjectDetailInitial());

  Future<void> loadObject(String id) async {
    emit(const ObjectDetailLoading());
    try {
      final object = await _repository.getObjectById(id);
      emit(ObjectDetailLoaded(object));
    } catch (e) {
      emit(const ObjectDetailError("Couldn't load object details."));
    }
  }

  Future<void> deleteObject(String id) async {
    try {
      await _repository.deleteObject(id);
      emit(const ObjectDeleted());
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 405) {
        emit(const ObjectDetailError(
          'Cannot delete pre-defined objects (IDs 1-13). '
          'You can only delete objects you created, or use authenticated mode.',
        ));
      } else {
        emit(const ObjectDetailError("Failed to delete object."));
      }
    }
  }
}
