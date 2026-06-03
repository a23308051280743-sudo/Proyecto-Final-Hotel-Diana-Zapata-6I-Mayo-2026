import 'package:flutter/material.dart';
import 'package:hotel/data/models/service.dart';
import 'package:hotel/data/services/firestore_service.dart';

class ServiceFormScreen extends StatefulWidget {
  final HotelService? service;
  const ServiceFormScreen({super.key, this.service});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name);
    _descriptionController = TextEditingController(text: widget.service?.description);
    _priceController = TextEditingController(text: widget.service?.price.toString());
    _categoryController = TextEditingController(text: widget.service?.category);
    _isActive = widget.service?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final service = HotelService(
      serviceId: widget.service?.serviceId ?? '',
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      category: _categoryController.text,
      isActive: _isActive,
      imageUrl: widget.service?.imageUrl,
    );

    try {
      if (widget.service == null) {
        await _firestoreService.createService(service);
      } else {
        await _firestoreService.updateService(widget.service!.serviceId, service.toMap());
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving service: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service == null ? 'Add Service' : 'Edit Service'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Service Name'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || double.tryParse(value) == null ? 'Please enter a valid price' : null,
            ),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a category' : null,
            ),
            SwitchListTile(
              title: const Text('Is Active'),
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Service'),
            ),
          ],
        ),
      ),
    );
  }
}
