// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSwitched = false;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? device;
  BluetoothCharacteristic? characteristic;

  @override
  void initState() {
    super.initState();
    _scanForDevices();
  }

  void _scanForDevices() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
        if (r.device.name == 'HC-06') {
          // Nombre del dispositivo Bluetooth HC-06
          device = r.device;
          flutterBlue.stopScan();
          _connectToDevice();
          break;
        }
      }
    });
  }

  void _connectToDevice() async {
    if (device == null) return;
    await device!.connect();
    List<BluetoothService> services = await device!.discoverServices();
    services.forEach((service) {
      service.characteristics.forEach((char) {
        // Reemplaza 'tu_UUID_de_característica' con el UUID de la característica de tu dispositivo
        if (char.uuid.toString() == 'tu_UUID_de_característica') {
          setState(() {
            characteristic = char;
          });
        }
      });
    });
  }

  void _toggleSwitch(bool value) {
    setState(() {
      isSwitched = value;
    });

    _sendToArduino(value);
  }

  void _sendToArduino(bool value) async {
    if (characteristic == null) return;
    // Enviar '1' para encender las luces, '0' para apagarlas
    await characteristic!.write([value ? 1 : 0]);
    print('Estado enviado a Arduino: $value');
  }

  void _launchURL() async {
    final Uri url = Uri.parse('https://www.google.com'); // Reemplaza con tu URL
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'No se pudo lanzar $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        centerTitle: true,
        title: Text(''),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/logo.png'),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 10),
            Text(
              'Domus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'domus024@gmail.com',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Encender Luces',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                Switch(
                  value: isSwitched,
                  onChanged: _toggleSwitch,
                  activeColor: Colors.green,
                ),
              ],
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: _launchURL,
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Sobre nosotros',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
