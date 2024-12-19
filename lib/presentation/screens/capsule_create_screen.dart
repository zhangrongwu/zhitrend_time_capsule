import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CapsuleCreateScreen extends StatefulWidget {
  const CapsuleCreateScreen({super.key});

  @override
  State<CapsuleCreateScreen> createState() => _CapsuleCreateScreenState();
}

class _CapsuleCreateScreenState extends State<CapsuleCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _unlockDate = DateTime.now().add(const Duration(days: 365));
  List<String> _contents = [];

  Future<void> _selectUnlockDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _unlockDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _unlockDate) {
      setState(() {
        _unlockDate = picked;
      });
    }
  }

  void _addContent() {
    showDialog(
      context: context,
      builder: (context) {
        String newContent = '';
        return AlertDialog(
          title: const Text('添加内容'),
          content: TextField(
            onChanged: (value) => newContent = value,
            decoration: const InputDecoration(
              hintText: '输入你想保存的内容',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (newContent.isNotEmpty) {
                  setState(() {
                    _contents.add(newContent);
                  });
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _createCapsule() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // TODO: 实现创建胶囊的逻辑
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('时间胶囊创建成功！')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建时间胶囊'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '胶囊标题',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入胶囊标题';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '描述',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('解锁日期'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_unlockDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectUnlockDate(context),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _addContent,
                icon: const Icon(Icons.add),
                label: const Text('添加内容'),
              ),
              const SizedBox(height: 16),
              ..._contents.map((content) => ListTile(
                    title: Text(content),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _contents.remove(content);
                        });
                      },
                    ),
                  )),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _createCapsule,
                child: const Text('创建时间胶囊'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
