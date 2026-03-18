import 'package:equatable/equatable.dart';

class ApiObject extends Equatable {
  final String id;
  final String name;
  final Map<String, dynamic>? data;
  final String? createdAt;
  final String? updatedAt;

  const ApiObject({
    required this.id,
    required this.name,
    this.data,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiObject.fromJson(Map<String, dynamic> json) {
    return ApiObject(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (data != null) 'data': data,
    };
  }

  ApiObject copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? data,
    String? createdAt,
    String? updatedAt,
  }) {
    return ApiObject(
      id: id ?? this.id,
      name: name ?? this.name,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, data, createdAt, updatedAt];
}
