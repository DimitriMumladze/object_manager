import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/api_object_model.dart';
import '../bloc/object_form_cubit.dart';
import '../bloc/object_list_bloc.dart';
import '../bloc/object_list_event.dart';

class ObjectFormScreen extends StatefulWidget {
  final ApiObject? existingObject;

  const ObjectFormScreen({super.key, this.existingObject});

  @override
  State<ObjectFormScreen> createState() => _ObjectFormScreenState();
}

class _ObjectFormScreenState extends State<ObjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final List<_DataField> _dataFields = [];
  bool _hasChanges = false;

  bool get _isEditMode => widget.existingObject != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingObject?.name ?? '',
    );
    _nameController.addListener(_onFormChanged);

    if (widget.existingObject?.data != null) {
      for (final entry in widget.existingObject!.data!.entries) {
        _dataFields.add(_DataField(
          keyController: TextEditingController(text: entry.key),
          valueController: TextEditingController(text: '${entry.value}'),
        ));
      }
    }

    if (_dataFields.isEmpty) {
      _addField();
    }
  }

  void _onFormChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final field in _dataFields) {
      field.keyController.dispose();
      field.valueController.dispose();
    }
    super.dispose();
  }

  void _addField() {
    setState(() {
      _dataFields.add(_DataField(
        keyController: TextEditingController(),
        valueController: TextEditingController(),
      ));
    });
  }

  void _removeField(int index) {
    setState(() {
      _dataFields[index].keyController.dispose();
      _dataFields[index].valueController.dispose();
      _dataFields.removeAt(index);
      _hasChanges = true;
    });
  }

  Map<String, dynamic> _buildDataMap() {
    final data = <String, dynamic>{};
    for (final field in _dataFields) {
      final key = field.keyController.text.trim();
      final value = field.valueController.text.trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        final numValue = num.tryParse(value);
        data[key] = numValue ?? value;
      }
    }
    return data;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final data = _buildDataMap();
    final cubit = context.read<ObjectFormCubit>();

    if (_isEditMode) {
      cubit.updateObject(
        id: widget.existingObject!.id,
        name: name,
        data: data.isEmpty ? null : data,
      );
    } else {
      cubit.createObject(name: name, data: data.isEmpty ? null : data);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final colors = AppColors.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to go back?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel',
                style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.go('/objects');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_hasChanges) {
                final shouldPop = await _onWillPop();
                if (shouldPop && context.mounted) {
                  context.go('/objects');
                }
              } else {
                context.go('/objects');
              }
            },
          ),
          title: Text(
            _isEditMode ? 'Edit Object' : 'Create Object',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          surfaceTintColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: colors.divider),
          ),
        ),
        body: BlocListener<ObjectFormCubit, ObjectFormState>(
          listener: (context, state) {
            if (state is ObjectFormSuccess) {
              final bloc = context.read<ObjectListBloc>();
              if (_isEditMode) {
                bloc.add(const RefreshObjects());
              } else {
                final obj = state.object;
                bloc.add(AddObjectToList(
                  id: obj.id,
                  name: obj.name,
                  data: obj.data,
                ));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isEditMode
                        ? 'Object updated successfully!'
                        : 'Object created successfully!',
                  ),
                  backgroundColor: colors.success,
                  duration: AppConstants.snackBarDuration,
                ),
              );
              context.go('/objects');
            }
            if (state is ObjectFormError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colors.error,
                ),
              );
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.all(AppConstants.screenPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Basic info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter object name',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Data Fields',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                            Text(
                              '${_dataFields.length} Fields',
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(_dataFields.length, (index) {
                          return _buildFieldRow(index, colors);
                        }),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _addField,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colors.border,
                                width: 1.5,
                                strokeAlign: BorderSide.strokeAlignInside,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline,
                                    size: 20, color: colors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Add Field',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(
                      top: BorderSide(color: colors.divider, width: 0.5),
                    ),
                  ),
                  child: BlocBuilder<ObjectFormCubit, ObjectFormState>(
                    builder: (context, state) {
                      final isSaving = state is ObjectFormSaving;
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: isSaving ? null : _save,
                          icon: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined, size: 20),
                          label: Text(
                            isSaving
                                ? 'Saving...'
                                : _isEditMode
                                    ? 'Update Object'
                                    : 'Save Object',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                colors.primary.withValues(alpha: 0.6),
                            disabledForegroundColor:
                                Colors.white.withValues(alpha: 0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldRow(int index, AppColors colors) {
    final field = _dataFields[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KEY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: field.keyController,
                      decoration: const InputDecoration(hintText: 'Key'),
                      onChanged: (_) => _onFormChanged(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VALUE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: field.valueController,
                      decoration: const InputDecoration(hintText: 'Value'),
                      onChanged: (_) => _onFormChanged(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: IconButton(
                  onPressed: _dataFields.length > 1
                      ? () => _removeField(index)
                      : null,
                  icon: Icon(
                    Icons.delete_outline,
                    color: _dataFields.length > 1
                        ? colors.textTertiary
                        : colors.divider,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DataField {
  final TextEditingController keyController;
  final TextEditingController valueController;

  _DataField({required this.keyController, required this.valueController});
}
