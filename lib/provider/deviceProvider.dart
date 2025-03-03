import 'package:solarhomes/model/deviceItem.dart';
import 'package:flutter/foundation.dart';
import 'package:solarhomes/database/deviceDB.dart';

class DeviceProvider with ChangeNotifier {
  List<DeviceItem> devices = [];

  List<DeviceItem> getDevices() {
    return devices;
  }

  void initData() async {
    var db = DeviceDB(dbName: 'devices.db');
    devices = await db.loadAllData();
    notifyListeners();
  }

  void addDevice(DeviceItem device) async {
    var db = DeviceDB(dbName: 'devices.db');
    await db.insertDatabase(device);
    devices = await db.loadAllData();
    notifyListeners();
  }

  deleteDevice(DeviceItem device) async {
    var db = DeviceDB(dbName: 'devices.db');
    await db.deleteData(device);
    devices = await db.loadAllData();
    notifyListeners();
  }

  void updateDevice(DeviceItem device) async {
    var db = DeviceDB(dbName: 'devices.db');
    await db.updateData(device);
    devices = await db.loadAllData();
    notifyListeners();
  }
}