import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

// Constantes para claves de almacenamiento
const String KEY_NUM1 = 'num1';
const String KEY_NUM2 = 'num2';
const String KEY_NUM3 = 'num3';

class SOSPage extends StatefulWidget {
  final VoidCallback onGoBack;

  const SOSPage({super.key, required this.onGoBack});

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  final List<String> _numberKeys = [KEY_NUM1, KEY_NUM2, KEY_NUM3];
  Map<String, String> _numbers = {
    KEY_NUM1: 'Num 1',
    KEY_NUM2: 'Num 2',
    KEY_NUM3: 'Num 3',
  };
  String? _selectedKey;

  @override
  void initState() {
    super.initState();
    _loadNumbers();
  }

  // --- Almacenamiento ---
  Future<void> _loadNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var key in _numberKeys) {
        _numbers[key] =
            prefs.getString(key) ?? 'Num ${_numberKeys.indexOf(key) + 1}';
      }
    });
  }

  Future<void> _saveNumber(String key, String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, number);
    _loadNumbers();
  }

  void _showRegisterDialog(String key) {
    TextEditingController controller = TextEditingController(
        text: _numbers[key]!.startsWith('Num') ? '' : _numbers[key]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registrar Número ${_numberKeys.indexOf(key) + 1}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: "Ingresa el número"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _saveNumber(key, controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar')),
        ],
      ),
    );
  }

  void _selectNumber(String key) {
    setState(() {
      _selectedKey = (key == _selectedKey) ? null : key;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Número seleccionado: ${_numbers[_selectedKey] ?? "Ninguno"}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // --- Opciones al mantener presionado ---
  void _showNumberOptionsDialog(String key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Opciones para ${_numbers[key]}'),
        content: const Text('¿Qué deseas hacer con este número?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showRegisterDialog(key); // Editar número
            },
            child: const Text('Editar'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove(key);
              _loadNumbers(); // Refrescar lista
              Navigator.pop(context);
            },
            child: const Text('Borrar', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  // --- Permisos ---
  Future<bool> _requestPermissions() async {
    var phoneStatus = await Permission.phone.request();
    var smsStatus = await Permission.sms.request();
    var locationStatus = await Permission.locationWhenInUse.request();

    if (phoneStatus.isGranted && smsStatus.isGranted && locationStatus.isGranted) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permisos de Llamada, SMS y Ubicación requeridos')),
      );
      return false;
    }
  }

  // --- Activar SOS ---
  Future<void> _triggerEmergency() async {
    if (_selectedKey == null) return;

    bool granted = await _requestPermissions();
    if (!granted) return;

    _startCall();
    await _sendSOSMessage();
  }

  // --- Llamada directa ---
  void _startCall() async {
    final numberToCall = _numbers[_selectedKey]!;
    await FlutterPhoneDirectCaller.callNumber(numberToCall);
  }

  // --- Envío de SMS ---
  Future<void> _sendSOSMessage() async {
    if (_selectedKey == null) return;

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener la ubicación.')),
      );
    }

    final String locationMessage = (position != null)
        ? '¡ALERTA SOS! Necesito ayuda. Ubicación: https://maps.google.com/?q=${position.latitude},${position.longitude}'
        : '¡ALERTA SOS! Necesito ayuda. Por favor llámame.';

    final phoneNumber = _numbers[_selectedKey]!;
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': locationMessage},
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mensaje enviado a $phoneNumber')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar mensaje a $phoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicio SOS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onGoBack,
        ),
        actions: [
          TextButton(
            onPressed: () => _showRegisterDialog(KEY_NUM1),
            child: const Text('REGISTRAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 10,
              children: _numberKeys.map((key) {
                bool selected = _selectedKey == key;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selected ? Colors.green : Colors.grey,
                  ),
                  onPressed: () => _selectNumber(key),
                  onLongPress: () => _showNumberOptionsDialog(key),
                  child: Text(_numbers[key]!),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _selectedKey != null ? _triggerEmergency : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                fixedSize: const Size(200, 200),
                shape: const CircleBorder(),
              ),
              child: const Text(
                'SOS',
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
