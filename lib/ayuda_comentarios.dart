import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AyudaComentarios extends StatefulWidget {
  const AyudaComentarios({super.key});

  @override
  State<AyudaComentarios> createState() => _AyudaComentariosState();
}

class _AyudaComentariosState extends State<AyudaComentarios> {
  final TextEditingController _opinionController = TextEditingController();
  bool _enviando = false;

  Future<void> _guardarOpinion() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No has iniciado sesión.")),
      );
      return;
    }

    final opinion = _opinionController.text.trim();

    if (opinion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escribe una opinión antes de enviar.")),
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(user.uid)
          .collection("opiniones")
          .add({
        "texto": opinion,
        "fecha": DateTime.now(),
      });

      _opinionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Gracias! Tu opinión fue enviada.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e")),
      );
    }

    setState(() => _enviando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // -----------------------
      // FLECHA DE REGRESO
      // -----------------------
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Ayuda y Comentarios",
          style: TextStyle(color: Colors.white),
        ),
      ),

      // -----------------------
      // CUERPO
      // -----------------------
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // -----------------------
            // CUADRO DE BIENVENIDA
            // -----------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Dinos en qué podemos mejorar.\nTu opinión es muy importante para nosotros.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // -----------------------
            // CUADRO DE TEXTO
            // -----------------------
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.black),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  controller: _opinionController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: "Escribe tu opinión aquí...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // -----------------------
            // BOTÓN ENVIAR
            // -----------------------
            GestureDetector(
              onTap: _enviando ? null : _guardarOpinion,
              child: Container(
                width: 140,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 2, color: Colors.black),
                ),
                alignment: Alignment.center,
                child: _enviando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Enviar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
