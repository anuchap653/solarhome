import 'package:solarhomes/model/deviceItem.dart';
import 'package:solarhomes/provider/deviceProvider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class EditScreen extends StatefulWidget {
  final DeviceItem item;

  const EditScreen({super.key, required this.item});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  String selectedStatus = 'กำลังใช้งาน';
  String? imageUrl; // เพิ่มตัวแปรสำหรับเก็บ URL ของรูปภาพ
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.item.title;
    selectedStatus = widget.item.status;
    imageUrl = widget.item.imageUrl; // กำหนดค่าเริ่มต้นจากรายการที่กำลังแก้ไข
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imageUrl = image.path; // เก็บ path ของรูปภาพ
      });
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: const Text('คุณต้องการลบรายการนี้ใช่หรือไม่?'),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ลบ'),
              onPressed: () {
                var provider = Provider.of<DeviceProvider>(context, listen: false);
                provider.deleteDevice(widget.item);
                Navigator.of(context).pop();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('ลบอุปกรณ์สำเร็จแล้ว'),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'รับทราบ',
                      onPressed: () {},
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('แก้ไขอุปกรณ์'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _confirmDelete(context);
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
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      var provider = Provider.of<DeviceProvider>(context, listen: false);

                      DeviceItem item = DeviceItem(
                        keyID: widget.item.keyID,
                        title: titleController.text,
                        status: selectedStatus,
                        imageUrl: imageUrl, // เก็บ URL ของรูปภาพ
                        date: widget.item.date,
                      );

                      provider.updateDevice(item);
                      Navigator.pop(context);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('แก้ไขข้อมูลสำเร็จ'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('แก้ไขข้อมูล'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}