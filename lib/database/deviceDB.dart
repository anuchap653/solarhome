import 'dart:io';
import 'package:solarhomes/model/deviceItem.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class DeviceDB {
  String dbName;

  DeviceDB({required this.dbName});

  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDir.path, dbName);
    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  Future<int> insertDatabase(DeviceItem item) async {
    var db = await openDatabase();

    var store = intMapStoreFactory.store('devices');

    Future<int> keyID = store.add(db, {
      'title': item.title,
      'status': item.status,
      'imageUrl': item.imageUrl, 
      'date': item.date?.toIso8601String()
    });
    db.close();
    return keyID;
  }

  Future<List<DeviceItem>> loadAllData() async {
    var db = await openDatabase();

    var store = intMapStoreFactory.store('devices');

    var snapshot = await store.find(db,
        finder: Finder(sortOrders: [SortOrder('date', false)]));

    List<DeviceItem> devices = [];

    for (var record in snapshot) {
      DeviceItem item = DeviceItem(
        keyID: record.key,
        title: record['title'].toString(),
        status: record['status'].toString(),
        imageUrl: record['imageUrl']?.toString(), 
        date: DateTime.parse(record['date'].toString()),
      );

      devices.add(item);
    }
    db.close();
    return devices;
  }

  deleteData(DeviceItem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('devices');
    store.delete(db,
        finder: Finder(filter: Filter.equals(Field.key, item.keyID)));
    db.close();
  }

  updateData(DeviceItem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('devices');

    store.update(
        db,
        {
          'title': item.title,
          'status': item.status,
          'imageUrl': item.imageUrl, // อัปเดต imageUrl
          'date': item.date?.toIso8601String()
        },
        finder: Finder(filter: Filter.equals(Field.key, item.keyID))
    );

    db.close();
  }
}