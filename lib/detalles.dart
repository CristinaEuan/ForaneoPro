import 'package:flutter/material.dart';

// Esta pantalla recibe el mapa de gastos de la semana
class DetallesPag extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> gastosSemana;

  const DetallesPag({super.key, required this.gastosSemana});

  @override
  Widget build(BuildContext context) {
    // Convierte el mapa de gastos en una lista de entradas para poder construir la lista.
    final List<MapEntry<String, List<Map<String, dynamic>>>> entradas = 
        gastosSemana.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles de Gastos Semanales"),
        // El botón de retroceso (flecha) se incluye automáticamente
      ),
      body: entradas.isEmpty
          ? const Center(
              child: Text(
                "Aún no hay detalles de gastos registrados.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: entradas.length,
              itemBuilder: (context, index) {
                final dia = entradas[index].key;
                final gastosDelDia = entradas[index].value;

                // 1. Calcular el total gastado ese día
                double totalDia = 0;
                for (var gasto in gastosDelDia) {
                  totalDia += gasto['cantidad'] as double;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título del día y Total
                        Text(
                          '$dia: Total gastado \$${totalDia.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const Divider(height: 15),

                        // Lista de Gastos Específicos del Día
                        ...gastosDelDia.map((gasto) {
                          final motivo = gasto['motivo'];
                          final cantidad = gasto['cantidad'].toStringAsFixed(2);
                          
                          return Padding(
                            padding: const EdgeInsets.only(left: 10, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '• $motivo',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '-\$$cantidad',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
