import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kontrol Arduino',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late UsbPort _port;
  bool _isConnected = false;
  TextEditingController _portController = TextEditingController();
  TextEditingController _bitrateController = TextEditingController();
  String _statusText = "";

  // Fungsi untuk mengirim data ke perangkat Arduino
  void kirimData() async {
    if (_isConnected) {
      String data = "1ag 2bh 3dg\n";
      _port.write(Uint8List.fromList(utf8.encode(data)));
      _updateStatus("Mengirim data: $data");
    } else {
      _updateStatus("Koneksi belum dibuka!");
    }
  }

  // Fungsi untuk membuka koneksi serial
  
  void bukaKoneksi() async {
    if (!kIsWeb) {
      // Plugin hanya digunakan di platform selain web (Android dan iOS)
      String portName = _portController.text;
      int bitrate = int.tryParse(_bitrateController.text) ?? 9600;

      try {
        List<UsbDevice> devices = await UsbSerial.listDevices();
        if (devices.isNotEmpty) {
          _port = (await devices[0].create())!;
          await _port.open();
          await _port.setDTR(true);
          await _port.setRTS(true);
          await _port.setPortParameters(bitrate, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
          setState(() {
            _isConnected = true;
          });
          _updateStatus("Terhubung ke $portName dengan bitrate $bitrate");
        } else {
          _updateStatus("Tidak ada perangkat USB yang terhubung.");
        }
      } catch (e) {
        _updateStatus("Gagal terhubung: $e");
      }
    } else {
      _updateStatus("Plugin tidak didukung di web.");
    }
  }



  // Fungsi untuk memperbarui label status
  void _updateStatus(String status) {
    setState(() {
      _statusText = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kontrol Arduino'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Port:'),
            TextField(controller: _portController),
            SizedBox(height: 16),
            Text('Bitrate:'),
            TextField(controller: _bitrateController),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: bukaKoneksi,
              child: Text('Buka Koneksi'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: kirimData,
              child: Text('Jalankan'),
              style: ElevatedButton.styleFrom(primary: _isConnected ? Colors.blue : Colors.grey),
            ),
            SizedBox(height: 16),
            Text(_statusText),
          ],
        ),
      ),
    );
  }
}
