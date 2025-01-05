import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RSAKeyModel()),
        ChangeNotifierProvider(create: (_) => BLEScanModel()),
        ChangeNotifierProvider(create: (_) => SignatureModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 212, 212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Image(
              image: AssetImage('imagens/logo.png'),
            ),
            const SizedBox(height: 30.0),
            const Text(
              "           Desafio Flutter \nfeito por Pedro Taglialenha",
              style: TextStyle(
                fontSize: 27.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                color: Colors.black,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 110.0),
                SizedBox(
                  width: 300,
                  height: 60,
                  child: ElevatedButton(
                    child: const Text(
                      "Dispositivos BLE",
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BLEScannerPage()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 300,
                  height: 60,
                  child: ElevatedButton(
                    child: const Text(
                      "Gerar chave RSA",
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RSAKeyGeneratorPage()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 300,
                  height: 60,
                  child: ElevatedButton(
                    child: const Text(
                      "Assinar lista",
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SigningPage()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 300,
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: ElevatedButton(
                      child: const Text(
                        "Verificar assinatura",
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const VerifySignaturePage()),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

///////////////////////// ASSINATURA /////////////////////////
class SignatureModel with ChangeNotifier {
  String _signature = '';
  String _signedData = '';
  String get signature => _signature;
  String get signedData => _signedData;

  void setSignature(String signature, String signedData) {
    _signature = signature;
    _signedData = signedData;
    notifyListeners();
  }
}

class SigningPage extends StatelessWidget {
  const SigningPage({Key? key}) : super(key: key);

  Future<void> _signData(BuildContext context, SignatureModel signatureModel,
      RSAKeyModel rsaKeyModel) async {
    final bleScanModel = context.read<BLEScanModel>();
    final devicesList = bleScanModel.devices
        .map((device) =>
            [device.name, device.id.toString(), device.lastScan.toString()])
        .toList();

    final message = jsonEncode(devicesList);
    final signature =
        await RSA.signPKCS1v15(message, Hash.SHA256, rsaKeyModel.privateKey);
    signatureModel.setSignature(signature, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 212, 212),
      appBar: AppBar(
        title: const Text('Assinatura de dados'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _signData(context,
                  context.read<SignatureModel>(), context.read<RSAKeyModel>()),
              child: const Text('Assinar'),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Consumer<SignatureModel>(
                builder: (context, signatureModel, child) {
                  final signature = signatureModel.signature;
                  return Text('Assinatura: \n$signature');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
///////////////////////// VERIFICAR  ASSINATURA /////////////////////////

class VerifySignaturePage extends StatefulWidget {
  const VerifySignaturePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _VerifySignaturePageState createState() => _VerifySignaturePageState();
}

class _VerifySignaturePageState extends State<VerifySignaturePage> {
  late String _signedData;
  late String _signature;
  bool _isVerified = false;

  @override
  Widget build(BuildContext context) {
    final signatureModel = context.watch<SignatureModel>();
    final rsaKeyModel = context.watch<RSAKeyModel>();
    final bleScanModel = context.watch<BLEScanModel>();

    final devicesList = bleScanModel.devices
        .map((device) =>
            [device.name, device.id.toString(), device.lastScan.toString()])
        .toList();
    _signedData = jsonEncode(devicesList);
    _signature = signatureModel.signature;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 212, 212),
      appBar: AppBar(
        title: const Text('Verificador de assinatura'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                _isVerified = await RSA.verifyPKCS1v15(
                  _signature,
                  _signedData,
                  Hash.SHA256,
                  rsaKeyModel.publicKey,
                );
                setState(() {});
              },
              child: const Text('Verificar Assinatura'),
            ),
            const SizedBox(height: 16),
            Text(
              _isVerified ? 'Assinatura é válida' : 'Assinatura não é válida',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: _isVerified ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///////////////////////// SCANNER BLE /////////////////////////
class BLEScanModel with ChangeNotifier {
  final List<BLEDevice> _devices = [];
  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  StreamSubscription? _scanSubscription;
  DateTime? _lastScan;

  List<BLEDevice> get devices => _devices;
  DateTime? get lastScan => _lastScan;

  Future<void> startScan() async {
    _scanSubscription?.cancel();
    _scanSubscription = _flutterBlue.scan().listen((scanResult) {
      final existingDeviceIndex = _devices
          .indexWhere((device) => device.id == scanResult.device.id.toString());
      final device =
          BLEDevice(scanResult.device, scanResult.rssi, DateTime.now());
      if (existingDeviceIndex >= 0) {
        _devices[existingDeviceIndex] = device;
      } else {
        _devices.add(device);
      }
      _lastScan = device.lastScan;
      notifyListeners();
    });
  }

  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  void setScanResults(List<BLEDevice> results) {
    _devices.clear();
    _devices.addAll(results);
    notifyListeners();
  }
}

class BLEDevice {
  final BluetoothDevice device;
  final int rssi;
  final DateTime lastScan;
  BLEDevice(this.device, this.rssi, this.lastScan);
  String get name => device.name;
  String get id => device.id.toString();
  int get signalStrength => rssi;
  String get address => device.id.id;
}

class BLEScannerPage extends StatefulWidget {
  const BLEScannerPage({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _BLEScannerPageState createState() => _BLEScannerPageState();
}

class _BLEScannerPageState extends State<BLEScannerPage> {
  late BLEScanModel _bleScanModel;
  DateTime _lastScanTime = DateTime.now();
  bool _isScanning = false;

  Future<void> _startScan() async {
    if (_isScanning) return;
    _isScanning = true;
    await _bleScanModel.startScan();
    setState(() {
      _lastScanTime = DateTime.now();
      _isScanning = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _bleScanModel = context.read<BLEScanModel>();
    _bleScanModel.startScan();
  }

  @override
  void dispose() {
    _bleScanModel.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<List<String>> devicesList = _bleScanModel.devices
        .map((device) =>
            [device.name, device.address, device.lastScan.toString()])
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner BLE'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Ultimo Scan: ${DateFormat.yMd().add_Hms().format(_lastScanTime)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                final device = devicesList[index];
                return ListTile(
                  title: Text(device[0]),
                  subtitle: Text(device[1]),
                  trailing: Text(device[2]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startScan,
        child: _isScanning
            ? const CircularProgressIndicator()
            : const Icon(Icons.bluetooth_searching),
      ),
    );
  }
}
///////////////////////// CHAVES RSA  /////////////////////////

class RSAKeyModel with ChangeNotifier {
  String _publicKey = '';
  String _privateKey = '';
  int _keySize = 2048;

  String get publicKey => _publicKey;
  String get privateKey => _privateKey;
  int get keySize => _keySize;

  set keySize(int value) {
    _keySize = value;
    notifyListeners();
  }

  Future<void> generateKeys() async {
    final keyPair = await RSA.generate(keySize);
    _publicKey = keyPair.publicKey;
    _privateKey = keyPair.privateKey;
    notifyListeners();
  }
}

class RSAKeyGeneratorPage extends StatefulWidget {
  const RSAKeyGeneratorPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RSAKeyGeneratorPageState createState() => _RSAKeyGeneratorPageState();
}

class _RSAKeyGeneratorPageState extends State<RSAKeyGeneratorPage> {
  final _formKey = GlobalKey<FormState>();
  late RSAKeyModel _rsaKeyModel;

  @override
  void initState() {
    super.initState();
    _rsaKeyModel = Provider.of<RSAKeyModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 212, 212),
      appBar: AppBar(
        title: const Text('Gerarador chaves RSA'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tamanho da chave',
                        ),
                        initialValue: _rsaKeyModel.keySize.toString(),
                        onSaved: (value) {
                          _rsaKeyModel.keySize = int.parse(value!);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor insira um tamanho de chave';
                          }
                          final keySize = int.tryParse(value);
                          if (keySize == null || keySize <= 0) {
                            return 'Por favor insira um tamanho de chave válido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                        }
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    await _rsaKeyModel.generateKeys();
                  },
                  child: const Text(
                    'Gerar novas chaves',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  child: const Text(
                    "   Chaves geradas   ",
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const KeyListScreen()),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///////////////////////// LISTA DE CHAVES /////////////////////////
class KeyListScreen extends StatelessWidget {
  const KeyListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rsaKeyModel = Provider.of<RSAKeyModel>(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 212, 212),
      appBar: AppBar(
        title: const Text('Chaves RSA'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chave Pública:'),
              const SizedBox(height: 8.0),
              SelectableText(rsaKeyModel.publicKey
                  // .replaceAll('-----BEGIN RSA PUBLIC KEY-----', '')
                  // .replaceAll('\n-----END RSA PUBLIC KEY-----', '')
                  ),
              const SizedBox(height: 16.0),
              const Text('Chave Privada:'),
              const SizedBox(height: 8.0),
              SelectableText(rsaKeyModel.privateKey
                  //.replaceAll('-----BEGIN RSA PRIVATE KEY-----\n', '')
                  // .replaceAll('\n-----END RSA PRIVATE KEY-----', '')
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
