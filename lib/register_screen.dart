import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear cuenta"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),

      body: Container(
        color: Colors.blue,   // MISMO COLOR QUE TU LOGIN
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
    onPressed: () {
      if (_formKey.currentState?.validate() ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registro enviado")),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context); // 🔥 regresa al login
        });
      }
    },
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Text("Registrarse"),
    ),
  ),
),


                    
                    // Texto "¿Ya tienes cuenta?"
                    
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
