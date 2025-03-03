import 'dart:io';
import 'package:solarhomes/model/deviceItem.dart';
import 'package:solarhomes/provider/deviceProvider.dart';
import 'package:flutter/material.dart';
import 'formScreen.dart';
import 'package:solarhomes/editScreen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          return DeviceProvider();
        })
      ],
      child: MaterialApp(
        title: 'ระบบบ้านพลังงานแสงอาทิตย์',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 19, 110, 7)),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false, // Remove the debug banner
        home: const MyHomePage(title: 'ระบบบ้านพลังงานแสงอาทิตย์'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double powerGeneration = 5000; // กำลังผลิตไฟฟ้า (วัตต์)
  double powerConsumption = 0; // การใช้ไฟฟ้า (วัตต์)
  double remainingEnergy = 0; // พลังงานที่เหลือ (วัตต์)

  @override
  void initState() {
    super.initState();

    DeviceProvider provider =
        Provider.of<DeviceProvider>(context, listen: false);
    provider.initData();
    provider.addListener(() {
      _calculatePowerConsumption(provider.devices);
    });
  }

  void _calculatePowerConsumption(List<DeviceItem> devices) {
    double totalConsumption = 0;
    for (var device in devices) {
      if (device.status == 'กำลังใช้งาน') {
      }
    }
    setState(() {
      powerConsumption = totalConsumption;
      remainingEnergy = powerGeneration - powerConsumption;
    });
  }

  void _toggleDeviceStatus(DeviceItem device, DeviceProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการเปลี่ยนสถานะ'),
          content: Text(device.status == 'กำลังใช้งาน'
              ? 'คุณต้องการปิดใช้งานอุปกรณ์นี้ใช่หรือไม่?'
              : 'คุณต้องการเปิดใช้งานอุปกรณ์นี้ใช่หรือไม่?'),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                setState(() {
                  device.status = device.status == 'กำลังใช้งาน' ? 'ไม่ได้ใช้งาน' : 'กำลังใช้งาน';
                  provider.updateDevice(device);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(device.status == 'กำลังใช้งาน'
                        ? 'เปิดใช้งานอุปกรณ์แล้ว'
                        : 'ปิดใช้งานอุปกรณ์แล้ว'),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'รับทราบ',
                      onPressed: () {},
                    ),
                  ),
                );

                Navigator.of(context).pop();
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
        leading: Icon(Icons.home, color: Colors.white),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const FormScreen();
              }));
            },
          ),
        ],
      ),
      body: Consumer<DeviceProvider>(
        builder: (context, provider, child) {
          List<DeviceItem> activeDevices = provider.devices
              .where((device) => device.status == 'กำลังใช้งาน')
              .toList();
          List<DeviceItem> inactiveDevices = provider.devices
              .where((device) => device.status != 'กำลังใช้งาน')
              .toList();
          List<DeviceItem> allDevices = [...activeDevices, ...inactiveDevices];

          return Column(
            children: [
              // แสดงข้อมูลพลังงาน
              Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ข้อมูลพลังงาน',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('กำลังการผลิตไฟฟ้า/วัน :'),
                          Text('${powerGeneration.toInt()} kW/day'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('การใช้ไฟฟ้า :'),
                          Text('${powerConsumption.toInt()} kW'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('พลังงานที่เหลือ :'),
                          Text('${remainingEnergy.toInt()} kW'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('จำนวนอุปกรณ์ที่กำลังใช้งานอยู่ :'),
                          Text('${activeDevices.length} เครื่อง'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('จำนวนอุปกรณ์ที่ไม่ได้ใช้งาน :'),
                          Text('${inactiveDevices.length} เครื่อง'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // แสดงรายการอุปกรณ์
              Expanded(
                child: allDevices.isEmpty
                    ? Center(
                        child: Text(
                          'ไม่มีรายการ',
                          style: TextStyle(fontSize: 24, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: allDevices.length,
                        itemBuilder: (context, int index) {
                          DeviceItem data = allDevices[index];
                          Color statusColor =
                              data.status == 'กำลังใช้งาน' ? Colors.green : Colors.red;

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: data.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(data.imageUrl!),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.device_unknown, size: 50),
                              title: Text(
                                data.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'จำนวนวัตต์: ${data.toString()} kW',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'วันที่: ${_formatDate(data.date)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'สถานะ: ${data.status}',
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  data.status == 'กำลังใช้งาน'
                                      ? Icons.power_off
                                      : Icons.power,
                                  color: data.status == 'กำลังใช้งาน'
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                onPressed: () {
                                  _toggleDeviceStatus(data, provider);
                                },
                              ),
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return EditScreen(item: data);
                                }));
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'ไม่มีวันที่';
    return '${date.day}/${date.month}/${date.year}';
  }
}