import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    super.dispose();
  }
  
  // ==========================================
  //          FUNCIÓN DE GUARDAR EN FIRESTORE
  // ==========================================
  Future<void> _saveUserData(String uid) async {
    final usersCollection = FirebaseFirestore.instance.collection('usuarios');

    // Usamos el UID de Firebase Auth como ID del documento en Firestore
    await usersCollection.doc(uid).set({
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'registration_date': Timestamp.now(),
    });
  }

  // ==========================================
  //          FUNCIÓN DE REGISTRO COMPLETO
  // ==========================================
  Future<void> _registerUser() async {
    // 1. Validar el formulario
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Si la validación falla, detiene la función
    }

    // Mostrar un indicador de carga (opcional pero recomendado)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registrando usuario..."), duration: Duration(seconds: 1)),
    );


    try {
      // 2. REGISTRAR USUARIO con Correo y Contraseña (Firebase Auth)
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. GUARDAR DATOS ADICIONALES en Firestore
      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!.uid);

        // 4. Mostrar éxito y navegar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("¡Registro exitoso!"),
              backgroundColor: Colors.green),
        );
        
        // Esperar un momento y luego regresar a la pantalla anterior (Login)
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pop(context); 
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      // 5. MANEJO DE ERRORES específicos de Firebase Auth
      String message;
      if (e.code == 'weak-password') {
        message = 'La contraseña es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Esta cuenta ya existe para ese correo.';
      } else {
        message = 'Error de registro: ${e.message}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      // 6. Manejo de otros errores (ej. de red o Firestore)
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ocurrió un error: $e"), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear cuenta"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),

      body: Container(
        color: Colors.blue, 
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // USERNAME
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: "Nombre de usuario",
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Ingresa un nombre de usuario";
                        }
                        if (value.length < 3) {
                          return "Mínimo 3 caracteres";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // CORREO
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Correo electrónico",
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Ingresa un correo";
                        }
                        if (!value.contains("@")) {
                          return "Correo inválido";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return "Mínimo 6 caracteres";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // CONFIRM PASSWORD
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: "Confirmar contraseña",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() => _obscureConfirmPassword =
                                !_obscureConfirmPassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return "Las contraseñas no coinciden";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // EDAD
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Edad",
                        prefixIcon: Icon(Icons.cake),
                      ),
                      validator: (value) {
                        final n = int.tryParse(value ?? '');
                        if (n == null || n < 1) {
                          return "Ingresa una edad válida";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // BOTÓN REGISTRAR
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: _registerUser, // <-- ¡Conectado a la función de Firebase!
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text("Registrarse"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}