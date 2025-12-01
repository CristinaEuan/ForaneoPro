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
              // ⭐ AQUÍ SE HACE LA LLAMADA A LA IMAGEN ⭐
              imagePath: 'lib/imagen_2/imag_costo.jpg', // <--- Revisa esta ruta
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
                imagePath: 'lib/imagen_2/sos.jpg',
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
      required VoidCallback onTap,
      // ⭐ 1. AÑADIR EL PARÁMETRO OPCIONAL DE LA IMAGEN ⭐
      String? imagePath}) {
        
    // Define el Decoration, incluyendo la imagen si se proporciona
    final decoration = BoxDecoration(
      // 2. USAR imagePath para crear el fondo
      color: (imagePath != null) ? color.withOpacity(0.5) : color,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(width: 2, color: Colors.black87),
      
      // Lógica para añadir la imagen
      image: (imagePath != null)
          ? DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover, // Para que la imagen cubra todo el botón
              // Filtro de color para oscurecer la imagen y que el texto se lea mejor
              colorFilter: ColorFilter.mode(
                color.withOpacity(0.5), 
                BlendMode.darken,
              ),
            )
          : null, // Si no hay ruta, no hay imagen.
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        // Usamos la nueva decoración que puede tener la imagen
        decoration: decoration, 
        alignment: Alignment.center,
        child: Text(
          text,
          // ⭐ 3. AÑADIR SOMBRAS AL TEXTO PARA MEJOR LECTURA (Opcional pero recomendado) ⭐
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2)
            ],
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
