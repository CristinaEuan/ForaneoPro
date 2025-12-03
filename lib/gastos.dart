import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'detalles.dart';

// Lista de motivos
const List<String> motivosGasto = [
  'Comida',
  'Cosas personales',
  'Gastos escolares',
  'Otros',
];

class GastosPag extends StatefulWidget {
  const GastosPag({super.key});

  @override
  State<GastosPag> createState() => _GastosPagState();
}

class _GastosPagState extends State<GastosPag> {
  bool _iniciado = false;
  double _dineroTotal = 0.0;
  double _dineroRestante = 0.0;

  String _mensaje =
      "¡Hola! Presiona 'Comenzar' para iniciar tu control semanal.";

  Map<String, List<Map<String, dynamic>>> _gastosSemana = {};

  @override
  void initState() {
    super.initState();
    _cargarDeMemoria(); // <--- CARGA AUTOMÁTICA
  }

  // ===============================
  //       SHARED PREFERENCES
  // ===============================

  Future<void> _guardarEnMemoria() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("iniciado", _iniciado);
    await prefs.setDouble("dineroTotal", _dineroTotal);
    await prefs.setDouble("dineroRestante", _dineroRestante);

    // Guardar gastos (en JSON)
    final jsonGastos = jsonEncode(_gastosSemana);
    await prefs.setString("gastosSemana", jsonGastos);
  }

  Future<void> _cargarDeMemoria() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("iniciado")) {
      setState(() {
        _iniciado = prefs.getBool("iniciado") ?? false;
        _dineroTotal = prefs.getDouble("dineroTotal") ?? 0.0;
        _dineroRestante = prefs.getDouble("dineroRestante") ?? 0.0;

        // Cargar gastos JSON
        final jsonString = prefs.getString("gastosSemana");
        if (jsonString != null) {
          final mapa =
              Map<String, dynamic>.from(jsonDecode(jsonString));

          // Convertir los valores dinámicos a Map<String,dynamic>
          _gastosSemana = mapa.map((key, value) {
            final lista = List<Map<String, dynamic>>.from(value);
            return MapEntry(key, lista);
          });
        }
      });
    }
  }

  // ===============================
  //       DÍA ACTUAL
  // ===============================

  String _getDiaActual() {
    final now = DateTime.now();
    final dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    return dias[now.weekday - 1];
  }

  // ===============================
  //       INICIAR CONTROL
  // ===============================

  void _iniciarControl() {
    setState(() {
      _iniciado = true;
      _mensaje = "Registra tu dinero";
    });

    _mostrarDialogoIngresarDinero();
  }

  Future<void> _mostrarDialogoIngresarDinero() async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("💵 Ingresa tu Dinero"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Cantidad inicial"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Siguiente"),
              onPressed: () {
                if (double.tryParse(controller.text) != null) {
                  setState(() {
                    _dineroTotal = double.parse(controller.text);
                    _dineroRestante = _dineroTotal;
                    _mensaje = "¡Control iniciado! Tienes \$$_dineroTotal.";
                  });

                  _guardarEnMemoria(); // <--- GUARDAR

                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ===============================
  //       AGREGAR GASTO
  // ===============================

  Future<void> _mostrarDialogoAgregarGasto() async {
    final TextEditingController controller = TextEditingController();
    String? motivoSeleccionado = motivosGasto.first;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSB) {
            return AlertDialog(
              title: const Text("💸 Registrar Gasto"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(hintText: "Cuánto gastaste"),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: motivoSeleccionado,
                    items: motivosGasto.map((motivo) {
                      return DropdownMenuItem(
                        value: motivo,
                        child: Text(motivo),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      setSB(() {
                        motivoSeleccionado = valor;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Cancelar"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text("Registrar"),
                  onPressed: () {
                    final gasto = double.tryParse(controller.text);
                    if (gasto != null && gasto > 0) {
                      _guardarGasto(gasto, motivoSeleccionado!);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _guardarGasto(double cantidad, String motivo) {
    setState(() {
      _dineroRestante -= cantidad;

      final dia = _getDiaActual();
      if (!_gastosSemana.containsKey(dia)) {
        _gastosSemana[dia] = [];
      }

      _gastosSemana[dia]!.add({
        "motivo": motivo,
        "cantidad": cantidad,
      });
    });

    _guardarEnMemoria(); // <--- GUARDAR CADA VEZ
  }

  // ===============================
  //       BARRAS
  // ===============================

  Widget _graficoDeBarras() {
    if (!_iniciado || _gastosSemana.isEmpty) {
      return const Center(child: Text("No hay gastos registrados esta semana."));
    }

    Map<String, double> gastosPorMotivo = {};

    _gastosSemana.forEach((dia, lista) {
      for (var gasto in lista) {
        final motivo = gasto['motivo'];
        final cantidad = gasto['cantidad'];
        gastosPorMotivo[motivo] =
            (gastosPorMotivo[motivo] ?? 0) + cantidad;
      }
    });

    final total = gastosPorMotivo.values.fold(0.0, (a, b) => a + b);

    return ListView(
      children: gastosPorMotivo.entries.map((e) {
        final porcentaje = e.value / total;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${e.key}: \$${e.value.toStringAsFixed(2)}"),
            LinearProgressIndicator(
              value: porcentaje,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 10,
            ),
            const SizedBox(height: 6),
          ],
        );
      }).toList(),
    );
  }

  // ===============================
  //       INTERFAZ EXACTA
  // ===============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Día de la semana: ${_getDiaActual()}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              if (!_iniciado)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(_mensaje,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        child: const Text("Comenzar"),
                        onPressed: _iniciarControl,
                      ),
                    ],
                  ),
                ),

              if (_iniciado)
                Row(
                  children: [
                    Expanded(
                      child: _infoBox(
                        title: "TENÍAS",
                        value: "\$${_dineroTotal.toStringAsFixed(2)}",
                        color: Colors.green.shade100,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _infoBox(
                        title: "TE QUEDA",
                        value: "\$${_dineroRestante.toStringAsFixed(2)}",
                        color: Colors.blue.shade100,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              if (_iniciado)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _mostrarDialogoAgregarGasto,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo),
                    child: const Text(
                      "AGREGAR GASTOS",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text("Gráfico de Gastos Semanales",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Divider(),
                      Expanded(child: _graficoDeBarras()),
                    ],
                  ),
                ),
              ),

              ElevatedButton(
                child: const Text("Ver detalles"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetallesPag(gastosSemana: _gastosSemana),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBox(
      {required String title,
      required String value,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }
}
