import 'package:flutter/material.dart';
import 'detalles.dart'; // Asegúrate de que el nombre del archivo sea correcto
// ...

// Definimos la lista de motivos de gasto para el diálogo
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
  // === VARIABLES DE ESTADO ===
  bool _iniciado = false;
  double _dineroTotal = 0.0;
  double _dineroRestante = 0.0;
  String _mensaje = "¡Hola! Presiona 'Comenzar' para iniciar tu control semanal.";

  // Para almacenar gastos: Clave: Día de la semana (String), Valor: Lista de pares [Motivo, Cantidad]
  Map<String, List<Map<String, dynamic>>> _gastosSemana = {};

  @override
  void initState() {
    super.initState();
    _dineroRestante = _dineroTotal; // Inicialmente, te queda todo lo que tienes
  }

  // === FUNCIONALIDADES ===

  // 1. Mostrar el día actual en tiempo real
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
    // Obtiene el día de la semana (1=Lunes, 7=Domingo)
    return dias[now.weekday - 1]; 
  }

  // 2. Lógica del botón 'Comenzar'
  void _iniciarControl() {
    setState(() {
      _iniciado = true;
      _mensaje = "Registra tu dinero";
    });

    // Muestra el diálogo para ingresar el dinero
    _mostrarDialogoIngresarDinero();
  }

  // 3. Diálogo para ingresar el dinero total
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                if (double.tryParse(controller.text) != null) {
                  setState(() {
                    _dineroTotal = double.parse(controller.text);
                    _dineroRestante = _dineroTotal;
                    _mensaje = "¡Control iniciado! Tienes \$$_dineroTotal.";
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Siguiente"),
            ),
          ],
        );
      },
    );
  }

  // 4. Diálogo y lógica para registrar un gasto
  Future<void> _mostrarDialogoAgregarGasto() async {
    final TextEditingController controller = TextEditingController();
    String? motivoSeleccionado = motivosGasto.first; // Motivo por defecto: Comida

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text("💸 Registrar Gasto"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Campo para la cantidad
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: "Cuánto gastaste"),
                  ),
                  const SizedBox(height: 15),
                  // Dropdown para los motivos
                  DropdownButtonFormField<String>(
                    value: motivoSeleccionado,
                    decoration: const InputDecoration(labelText: "Motivo"),
                    items: motivosGasto.map((String motivo) {
                      return DropdownMenuItem<String>(
                        value: motivo,
                        child: Text(motivo),
                      );
                    }).toList(),
                    onChanged: (String? nuevoMotivo) {
                      setStateSB(() { // Usa setStateSB para actualizar el diálogo
                        motivoSeleccionado = nuevoMotivo;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    final gasto = double.tryParse(controller.text);
                    if (gasto != null && motivoSeleccionado != null && gasto > 0) {
                      _guardarGasto(gasto, motivoSeleccionado!);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Registrar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 5. Función para guardar el gasto y actualizar el saldo
  void _guardarGasto(double cantidad, String motivo) {
    setState(() {
      // 5.1. Actualizar el dinero restante
      _dineroRestante -= cantidad;

      // 5.2. Registrar el gasto por día
      final diaActual = _getDiaActual();
      if (!_gastosSemana.containsKey(diaActual)) {
        _gastosSemana[diaActual] = [];
      }
      _gastosSemana[diaActual]!.add({
        'motivo': motivo,
        'cantidad': cantidad,
      });
    });
  }

  // 6. Widget de gráfico de barras simplificado
  Widget _graficoDeBarras() {
    if (!_iniciado || _gastosSemana.isEmpty) {
      return const Center(child: Text("No hay gastos registrados esta semana."));
    }

    // Calcula el total gastado por motivo para el gráfico
    Map<String, double> gastosPorMotivo = {};
    _gastosSemana.forEach((dia, listaGastos) {
      for (var gasto in listaGastos) {
        final motivo = gasto['motivo'] as String;
        final cantidad = gasto['cantidad'] as double;
        gastosPorMotivo[motivo] = (gastosPorMotivo[motivo] ?? 0.0) + cantidad;
      }
    });

    final totalSemanal = gastosPorMotivo.values.fold(0.0, (sum, item) => sum + item);
    
    // Muestra las barras
    return ListView(
      children: gastosPorMotivo.entries.map((entry) {
        final porcentaje = entry.value / totalSemanal;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${entry.key}: \$${entry.value.toStringAsFixed(2)}'),
              LinearProgressIndicator(
                value: porcentaje,
                backgroundColor: Colors.grey[300],
                color: entry.key == 'Comida' ? Colors.orange : Colors.blue, // Ejemplo de color
                minHeight: 10,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  // === ESTRUCTURA VISUAL (BUILD) ===

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // -----------------------
              //     FLECHA DE ANTERIOR (FUNCIONALIDAD 1)
              // -----------------------
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      // Vuelve a la vista PrincipalPag
                      Navigator.pop(context); 
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // -----------------------
              //     DÍA DE LA SEMANA (FUNCIONALIDAD 2)
              // -----------------------
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Día de la semana: ${_getDiaActual()}", // Muestra el día actual
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // -----------------------
              //     INICIO DEL CONTROL (FUNCIONALIDAD 3)
              // -----------------------
              if (!_iniciado)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _mensaje, // Mensaje "Registra tu dinero"
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _iniciarControl, // Ejecuta la lógica de inicio
                        child: const Text("Comenzar"),
                      ),
                    ],
                  ),
                ),

              // -----------------------
              //     DINERO TENÍAS / TE QUEDA (FUNCIONALIDAD 4)
              // -----------------------
              if (_iniciado)
                Row(
                  children: [
                    // TENÍAS
                    Expanded(
                      child: _infoBox(
                        title: "TENÍAS",
                        value: "\$${_dineroTotal.toStringAsFixed(2)}",
                        color: Colors.green.shade100,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // TE QUEDA (ACTUALIZACIÓN AUTOMÁTICA)
                    Expanded(
                      child: _infoBox(
                        title: "TE QUEDA",
                        value: "\$${_dineroRestante.toStringAsFixed(2)}",
                        color: _dineroRestante < 0 ? Colors.red.shade100 : Colors.blue.shade100, // Alerta si es negativo
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // -----------------------
              //     BOTÓN AGREGAR GASTOS (FUNCIONALIDAD 5)
              // -----------------------
              if (_iniciado)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _mostrarDialogoAgregarGasto,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("AGREGAR GASTOS", style: TextStyle(fontSize: 16)),
                  ),
                ),
              
              const SizedBox(height: 20),

              // -----------------------
              //     GRÁFICO DE BARRAS (FUNCIONALIDAD 6)
              // -----------------------
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Gráfico de Gastos Semanales", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      Expanded(
                        child: _graficoDeBarras(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
              // Botón "Ver detalles" (Placeholder)
              ElevatedButton(
                onPressed: () {
                  // Lógica para ver detalles
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetallesPag(
                        gastosSemana: _gastosSemana, // <--- Pasamos el mapa de gastos
                      ),
                    ),
                  );
                },
                child: const Text("Ver detalles"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para las cajas de información (TENÍAS/TE QUEDA)
  Widget _infoBox({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }
}