import 'package:solarhomes/model/deviceItem.dart';
import 'package:solarhomes/provider/deviceProvider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  String selectedStatus = 'กำลังใช้งาน';
  String? imageUrl; // เพิ่มตัวแปรสำหรับเก็บ URL ของรูปภาพ
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imageUrl = image.path; // เก็บ path ของรูปภาพ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('เพิ่มอุปกรณ์'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                var provider = Provider.of<DeviceProvider>(context, listen: false);

                DeviceItem item = DeviceItem(
                  title: titleController.text,
                  status: selectedStatus,
                  imageUrl: imageUrl, // เก็บ URL ของรูปภาพ
                  date: DateTime.now(),
                );

                provider.addDevice(item);
                Navigator.pop(context);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('เพิ่มข้อมูลสำเร็จ'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    label: const Text('ชื่ออุปกรณ์'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  autofocus: true,
                  controller: titleController,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "กรุณาป้อนชื่ออุปกรณ์";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    label: const Text('จำนวนการใช้วัตต์'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "กรุณาป้อนจำนวนการใช้วัตต์";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ToggleButtons(
                  isSelected: [selectedStatus == 'กำลังใช้งาน', selectedStatus == 'ไม่ได้ใช้งาน'],
                  onPressed: (int index) {
                    setState(() {
                      selectedStatus = index == 0 ? 'กำลังใช้งาน' : 'ไม่ได้ใช้งาน';
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('กำลังใช้งาน'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('ไม่ได้ใช้งาน'),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8.0),
                  selectedColor: const Color.fromARGB(255, 0, 0, 0),
                  fillColor: Theme.of(context).colorScheme.primary,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('เลือกรูปภาพ'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 24.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                if (imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(imageUrl!),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}