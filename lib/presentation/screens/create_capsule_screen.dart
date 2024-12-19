import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../domain/providers/capsule_provider.dart';
import '../../domain/providers/user_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class CreateCapsuleScreen extends StatefulWidget {
  static const routeName = '/create-capsule';

  const CreateCapsuleScreen({Key? key}) : super(key: key);

  @override
  _CreateCapsuleScreenState createState() => _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends State<CreateCapsuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime? _selectedUnlockTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectUnlockTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedUnlockTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitCapsule() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedUnlockTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请选择解锁时间')),
        );
        return;
      }

      final capsuleProvider = context.read<CapsuleProvider>();
      final userProvider = context.read<UserProvider>();

      final result = await capsuleProvider.createCapsule(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        unlockTime: _selectedUnlockTime!,
        content: _contentController.text.trim(),
      );

      if (result != null) {
        Navigator.of(context).pop(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(capsuleProvider.error ?? '创建时间胶囊失败')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final capsuleProvider = context.watch<CapsuleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('创建时间胶囊'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _titleController,
                  labelText: '胶囊标题',
                  hintText: '给你的时间胶囊一个有意义的标题',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入胶囊标题';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  labelText: '描述',
                  hintText: '简单描述这个时间胶囊的意义',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _contentController,
                  labelText: '胶囊内容',
                  hintText: '写下你想在未来看到的内容',
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _selectUnlockTime,
                  child: Text(
                    _selectedUnlockTime == null
                        ? '选择解锁时间'
                        : '解锁时间：${DateFormat('yyyy-MM-dd HH:mm').format(_selectedUnlockTime!)}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  onPressed: capsuleProvider.isLoading ? null : _submitCapsule,
                  child: capsuleProvider.isLoading
                      ? const CircularProgressIndicator.adaptive()
                      : const Text('创建时间胶囊'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
