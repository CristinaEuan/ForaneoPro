import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foraneaoapp/ayuda_comentarios.dart';
import 'package:foraneaoapp/gastos.dart';
import 'package:foraneaoapp/sos.dart';
import 'package:foraneaoapp/usuario.dart'; // 👈 IMPORTANTE

// ------------------------------------------------------------------
//     LISTA DE FRASES MOTIVADORAS
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
// *** PANTALLA PRINCIPAL – NOW STATEFUL WIDGET ***
// ***************************************************************
class PrincipalPag extends StatefulWidget {
  const PrincipalPag({super.key});

  @override
  State<PrincipalPag> createState() => _PrincipalPagState();
}

class _PrincipalPagState extends State<PrincipalPag> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _fraseActual = "";

  @override
  void initState() {
    super.initState();
    _seleccionarFraseAleatoria();
  }

  void _seleccionarFraseAleatoria() {
    final random = Random();
    final int indice = random.nextInt(frasesMotivadoras.length);

    setState(() {
      _fraseActual = frasesMotivadoras[indice];
    });
  }

  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 2)),
    );
  }

  // ----------------------------------------------------------
  //  FUNCIÓN PARA CERRAR SESIÓN
  // ----------------------------------------------------------
  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      "/login",
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // ***************************************************
      //                    MENÚ LATERAL
      // ***************************************************
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text(
                'Opciones de ForaneoPro',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.brightness_4),
              title: const Text('Modo Oscuro / Brillo'),
              onTap: () {
                Navigator.pop(context);
                _mostrarMensaje(context, "Función en desarrollo!");
              },
            ),

            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Ayuda y Comentarios'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AyudaComentarios()),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                _cerrarSesion();
              },
            ),
          ],
        ),
      ),

      // ***************************************************
      //                      CUERPO
      // ***************************************************
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // BARRA SUPERIOR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 👇 ICONO DE USUARIO AHORA ABRE LA VISTA UsuarioPag()
                  _hexagonButton(
                    icon: Icons.person,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UsuarioPag()),
                      );
                    },
                  ),

                  _hexagonButton(
                    icon: Icons.menu,
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // FRASE MOTIVADORA
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
                    _fraseActual,
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

              // CONTROL DE GASTOS
              _rectButton(
                context,
                text: "Control de gastos",
                color: Colors.green.shade400,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GastosPag()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // COCINEMOS
              _rectButton(
                context,
                text: "Cocinemos",
                color: Colors.orange.shade400,
                onTap: () {},
              ),

              const SizedBox(height: 20),

              // SOS
              _rectButton(
                context,
                text: "SOS",
                color: Colors.red.shade400,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SOSPage(
                        onGoBack: () => Navigator.pop(context),
                      ),
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

  // BOTÓN HEXÁGONO
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

  // BOTÓN RECTANGULAR
  Widget _rectButton(
    BuildContext context, {
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
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

// HEXAGON SHAPE
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
