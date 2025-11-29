import 'package:flutter/material.dart';

class PrincipalPag extends StatelessWidget {
  const PrincipalPag({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // -----------------------
              //     BARRA SUPERIOR
              // -----------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _hexagonButton(
                    icon: Icons.person,
                    onTap: () {},
                  ),
                  _hexagonButton(
                    icon: Icons.menu,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // -----------------------
              //    FRASE MOTIVADORA
              // -----------------------
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade300,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 3),
                ),
                alignment: Alignment.center,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "El éxito financiero empieza con pequeños pasos.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // -----------------------
              //  RECTÁNGULO 1 – GASTOS
              // -----------------------
              _rectButton(
                context,
                text: "Control de gastos",
                color: Colors.green.shade400,
                onTap: () {
                  // Navegación
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Placeholder()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // -----------------------
              //  RECTÁNGULO 2 – COCINEMOS
              // -----------------------
              _rectButton(
                context,
                text: "Cocinemos",
                color: Colors.orange.shade400,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Placeholder()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // -----------------------
              //  RECTÁNGULO 3 – SOS
              // -----------------------
              _rectButton(
                context,
                text: "SOS",
                color: Colors.red.shade400,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Placeholder()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================================
  //     WIDGET: BOTÓN HEXAGONAL
  // ===================================
  Widget _hexagonButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipPath(
        clipper: _HexagonClipper(),
        child: Container(
          width: 55,
          height: 55,
          color: Colors.black,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  // ===================================
  //     WIDGET: RECTÁNGULO BOTÓN
  // ===================================
  Widget _rectButton(BuildContext context,
      {required String text,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 2, color: Colors.black87),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ======================================
//     CLIPPER PARA FORMAR HEXÁGONOS
// ======================================
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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
