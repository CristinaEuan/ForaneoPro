import 'package:flutter/material.dart';
import 'package:foraneaoapp/gastos.dart';
import 'dart:math'; // Necesitas esta librería para usar Random

// ------------------------------------------------------------------
//     LISTA DE FRASES MOTIVADORAS
// ------------------------------------------------------------------
const List<String> frasesMotivadoras = [
  "El éxito financiero empieza con pequeños pasos.", 
  "Cada gasto es una decisión, hazla consciente.",
  "Invierte en experiencias, no en cosas.",
  "La disciplina es el puente entre metas y logros.",
  "No cuentes los días, haz que los días cuenten.",
  "Tu futuro económico te lo agradecerá.",
  "Ahorrar no es guardar, es planificar la libertad.",
  "Sé más fuerte que tus excusas financieras.",
  "El control te da el poder sobre tu dinero.",
  "Pequeños cambios hacen grandes diferencias.",
  "Hoy es el día para empezar a construir tu fortuna.",
  "Gastar menos de lo que ganas es la clave.",
  "Un presupuesto es decirle a tu dinero a dónde ir.",
  "No esperes el momento perfecto, tómalo.",
  "El valor de un sueño no tiene precio.",
  "Siempre hay una solución, si estás dispuesto a buscarla.",
  "La perseverancia vence a la resistencia.",
  "Cada error financiero es una lección valiosa.",
  "Organización es sinónimo de tranquilidad.",
  "Tu meta es tu motivación más grande.", 
];

// ***************************************************************
// *** CONVERTIMOS A STATEFUL PARA MANEJAR EL CAMBIO DE FRASE ***
// ***************************************************************
class PrincipalPag extends StatefulWidget {
  const PrincipalPag({super.key});

  @override
  State<PrincipalPag> createState() => _PrincipalPagState();
}

class _PrincipalPagState extends State<PrincipalPag> {
  // Clave para poder acceder al Scaffold y abrir el Drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // <--- CLAVE PARA EL MENÚ

  // Variable para guardar la frase seleccionada
  String _fraseActual = "";

  @override
  void initState() {
    super.initState();
    _seleccionarFraseAleatoria(); // Llama a la función al iniciar la pantalla
  }

  void _seleccionarFraseAleatoria() {
    final random = Random();
    // Selecciona un índice aleatorio basado en la longitud de la lista
    final int indiceAleatorio = random.nextInt(frasesMotivadoras.length);
    
    setState(() {
      _fraseActual = frasesMotivadoras[indiceAleatorio];
    });
  }

  // Función auxiliar para mostrar mensajes (Snackbars) - Útil para las opciones del Drawer
  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Asignar la clave al Scaffold
      
      // **********************************************
      // ***            MENÚ LATERAL (DRAWER)         ***
      // **********************************************
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Encabezado del Drawer
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Text(
                'Opciones de ForaneoPro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            
            // Opción 1: Modo Oscuro / Brillo
            ListTile(
              leading: const Icon(Icons.brightness_4),
              title: const Text('Modo Oscuro / Brillo'),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                _mostrarMensaje(context, "Funcionalidad de tema en desarrollo!");
              },
            ),

            // Opción 2: Ayuda y Comentarios
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Ayuda y Comentarios'),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                _mostrarMensaje(context, "¡Gracias por tu feedback! Pantalla de Ayuda.");
              },
            ),
            
            const Divider(),
            
            // Opción 3: Cerrar Sesión
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                _mostrarMensaje(context, "Cerrando Sesión...");
              },
            ),
          ],
        ),
      ),
      // **********************************************

      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // -----------------------
              //     BARRA SUPERIOR
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
                    onTap: () {
                      // LLAMADA PARA ABRIR EL DRAWER
                      _scaffoldKey.currentState?.openDrawer(); 
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // -----------------------
              //    FRASE MOTIVADORA (USA _fraseActual)
              // -----------------------
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade300,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 3),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _fraseActual, // <-- Frase aleatoria
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // -----------------------
              //  RECTÁNGULO 1 – GASTOS
              // -----------------------
              _rectButton(
                context,
                text: "Control de gastos",
                color: Colors.green.shade400,
                onTap: () {
                  // Navegación a la nueva pantalla GastosPag
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GastosPag()), 
                  );
                },
              ),

              const SizedBox(height: 20),

              // -----------------------
              //  RECTÁNGULO 2 – COCINEMOS
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
              //  RECTÁNGULO 3 – SOS
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
  //     WIDGET: BOTÓN HEXAGONAL
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
  //     WIDGET: RECTÁNGULO BOTÓN
  // ===================================
  Widget _rectButton(BuildContext context,
      {required String text,
      required Color color,
      required VoidCallback onTap,
      String? imagePath}) {
        
    final decoration = BoxDecoration(
      color: (imagePath != null) ? color.withOpacity(0.5) : color,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(width: 2, color: Colors.black87),
      
      image: (imagePath != null)
          ? DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover, 
              colorFilter: ColorFilter.mode(
                color.withOpacity(0.5), 
                BlendMode.darken,
              ),
            )
          : null, 
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: decoration, 
        alignment: Alignment.center,
        child: Text(
          text,
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
//     CLIPPER PARA FORMAR HEXÁGONOS
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