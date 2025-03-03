class DeviceItem {
  int? keyID;
  String title;
  String status;
  String? imageUrl; // เพิ่มฟิลด์สำหรับเก็บ URL ของรูปภาพ
  DateTime? date;

  DeviceItem({
    this.keyID,
    required this.title,
    this.status = 'กำลังใช้งาน',
    this.imageUrl,
    this.date,
  });
}