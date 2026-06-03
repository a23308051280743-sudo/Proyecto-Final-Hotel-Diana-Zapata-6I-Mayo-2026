import 'package:flutter/material.dart';
import 'package:hotel/data/models/user.dart';
import 'package:hotel/data/services/firestore_service.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _uidController;
  String _role = 'guest';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name);
    _emailController = TextEditingController(text: widget.user?.email);
    _phoneController = TextEditingController(text: widget.user?.phone);
    _uidController = TextEditingController(text: widget.user?.uid);
    _role = widget.user?.role ?? 'guest';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = User(
      uid: _uidController.text,
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      role: _role,
      createdAt: widget.user?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.user == null) {
        await _firestoreService.createUser(user);
      } else {
        await _firestoreService.updateUserData(user.uid, user.toMap());
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving user: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Add User' : 'Edit User'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _uidController,
              decoration: const InputDecoration(labelText: 'User ID (UID)'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter UID' : null,
              enabled: widget.user == null,
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter name' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter email' : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter phone' : null,
            ),
            DropdownButtonFormField<String>(
              initialValue: _role,
              items: ['guest', 'user', 'admin'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) => setState(() => _role = val!),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save User'),
            ),
          ],
        ),
      ),
    );
  }
}
