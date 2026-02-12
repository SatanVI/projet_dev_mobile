import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campus_events_app/utils.dart';
import 'package:campus_events_app/services/notification_service.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descController = TextEditingController();

  Uint8List? _selectedImage;
  DateTime? selectedDate;
  bool isFeatured = false;

  @override
  void initState() {
    super.initState();
    NotificationService().init();
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 600,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _selectedImage = bytes);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _uploadEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDate == null) {
      showMessage(context, "Veuillez sélectionner une date", isError: true);
      return;
    }

    showMessage(context, "Ajout de l'événement en cours...");

    try {
      await FirebaseFirestore.instance.collection("events").add({
        "title": titleController.text,
        "description": descController.text,
        "image_url": _selectedImage != null
            ? base64Encode(_selectedImage!)
            : "",
        "date": selectedDate,
        "is_featured": isFeatured,
        "created_at": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        await NotificationService().showNotification(
          "Événement ajouté",
          "L'événement '${titleController.text}' a été créé avec succès !",
        );
        showMessage(context, "Événement ajouté avec succès !");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showMessage(context, "Erreur : $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8ECF4),
      appBar: AppBar(
        title: const Text("Ajouter un événement"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: titleController,
                label: "Titre",
                icon: Icons.title,
              ),
              const SizedBox(height: 15),
              _buildImageSelector(),
              const SizedBox(height: 15),
              _buildDateSelector(),
              const SizedBox(height: 15),

              _buildTextField(
                controller: descController,
                label: "Description",
                icon: Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              SwitchListTile(
                title: const Text("Mettre à la une ?"),
                value: isFeatured,
                activeColor: const Color(0xFF0F4E7F),
                onChanged: (val) => setState(() => isFeatured = val),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _uploadEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4E7F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Ajouter l'événement",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(_selectedImage!, fit: BoxFit.cover),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                  Text(
                    "Ajouter une image",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
              selectedDate == null
                  ? "Sélectionner une date"
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              style: TextStyle(
                color: selectedDate == null ? Colors.grey : Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.isEmpty ? "Ce champ est requis" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
