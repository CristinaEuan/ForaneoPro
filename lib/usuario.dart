import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsuarioPag extends StatefulWidget {
  const UsuarioPag({super.key});

  @override
  State<UsuarioPag> createState() => _UsuarioPagState();
}

class _UsuarioPagState extends State<UsuarioPag> {
  String nombre = "";
  String correo = "";
  String edad = "";

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      nombre = data["username"] ?? "";
      correo = data["email"] ?? "";
      edad = data["age"] != null ? data["age"].toString() : "";
    }

    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil del Usuario"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Ícono de usuario con hexágono
                  ClipPath(
                    clipper: _HexagonClipper(),
                    child: Container(
                      width: 140,
                      height: 140,
                      color: Colors.black,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 90,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Cuadro de datos
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(width: 2),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dato("Nombre de usuario:", nombre),
                          const SizedBox(height: 20),

                          _dato("Correo:", correo),
                          const SizedBox(height: 20),

                          _dato("Edad:", edad),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _dato(String titulo, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          valor.isNotEmpty ? valor : "No registrado",
          style: const TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

// Clip de hexágono
class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    return Path()
      ..moveTo(w * 0.25, 0)
      ..lineTo(w * 0.75, 0)
      ..lineTo(w, h * 0.5)
      ..lineTo(w * 0.75, h)
      ..lineTo(w * 0.25, h)
      ..lineTo(0, h * 0.5)
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}
