import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/upt_service.dart';
import '../widgets/map_widget.dart';
import 'schedule_screen.dart';
import 'admin_salon_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _imagenController = TextEditingController();
  bool _isLoading = false;
  String _captchaUrl = 'https://net.upt.edu.pe/imagen.php';
  final UptService _service = UptService();
  Future<List<int>?>? _captchaImageFuture;

  @override
  void initState() {
    super.initState();
    _initializeCaptcha();
  }

  Future<void> _initializeCaptcha() async {
    try {
      final newUrl = await _service.initializeSession();
      setState(() {
        _captchaUrl = newUrl;
      });
    } catch (e) {
      print('Error inicializando CAPTCHA: $e');
      setState(() {
        _captchaUrl =
            'https://net.upt.edu.pe/imagen.php?${DateTime.now().millisecondsSinceEpoch}';
      });
    }
  }

  Future<void> _refreshCaptcha() async {
    try {
      _imagenController.clear();
      final newUrl = await _service.refreshSession();
      setState(() {
        _captchaUrl = newUrl;
        _captchaImageFuture = null;
      });
    } catch (e) {
      print('Error refrescando CAPTCHA: $e');
      setState(() {
        _captchaUrl =
            'https://net.upt.edu.pe/imagen.php?${DateTime.now().millisecondsSinceEpoch}';
        _captchaImageFuture = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3B82F6), // Azul brillante
              Color(0xFF1E40AF), // Azul oscuro
              Color(0xFF0F172A), // Azul muy oscuro
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 20,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo y título
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '¿Dónde mi Salón?',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sistema de Horarios UPT',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Campo de código/email
                        TextFormField(
                          controller: _codigoController,
                          decoration: InputDecoration(
                            labelText: 'CÓDIGO o EMAIL',
                            hintText: 'Ingrese su código de estudiante o email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF3B82F6),
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Color(0xFF64748B),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su código o email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Campo de contraseña
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'CONTRASEÑA',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF3B82F6),
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color(0xFF64748B),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Sección CAPTCHA
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Código de Verificación CAPTCHA',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Imagen del CAPTCHA
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFFD1D5DB),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: FutureBuilder<List<int>?>(
                                          future: _captchaImageFuture ??=
                                              _service.loadCaptchaImage(),
                                          key: ValueKey(_captchaUrl),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            } else if (snapshot.hasData &&
                                                snapshot.data != null) {
                                              return Image.memory(
                                                Uint8List.fromList(
                                                  snapshot.data!,
                                                ),
                                                fit: BoxFit.contain,
                                              );
                                            } else {
                                              return const Center(
                                                child: Text(
                                                  'Error\nCAPTCHA',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF3B82F6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _refreshCaptcha,
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                      ),
                                      tooltip: 'Actualizar CAPTCHA',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Campo de entrada del CAPTCHA
                              TextFormField(
                                controller: _imagenController,
                                decoration: InputDecoration(
                                  labelText: 'Código CAPTCHA',
                                  hintText: 'Ingrese los 4 dígitos',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3B82F6),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el código CAPTCHA';
                                  }
                                  if (value.length != 4) {
                                    return 'El código debe tener 4 dígitos';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Botón de login
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'INICIAR SESIÓN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Texto de ayuda
                        const Text(
                          'Ingrese sus credenciales institucionales\npara acceder al sistema',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Verificar si son credenciales de administrador
      if (_codigoController.text == 'admin123@gmail.com' &&
          _passwordController.text == 'admin123') {
        // Login como administrador
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AdminScreen()),
        );
        return;
      }

      // Login normal de estudiante
      final success = await _service.login(
        codigo: _codigoController.text,
        password: _passwordController.text,
        imagen: _imagenController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ScheduleScreen(service: _service),
          ),
        );
      } else {
        _showError(
          'Credenciales incorrectas. Verifique:\n• Código de estudiante\n• Contraseña\n• Código CAPTCHA (4 dígitos)',
        );
        _refreshCaptcha();
      }
    } catch (e) {
      _showError(
        'Error de conexión con la intranet UPT.\nVerifique su conexión a internet.',
      );
      _refreshCaptcha();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _passwordController.dispose();
    _imagenController.dispose();
    super.dispose();
  }
}

// Pantalla del administrador
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('¿Dónde mi Salón? - Admin'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bienvenida administrativa
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 60,
                      color: Color(0xFF3B82F6),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Bienvenido Administrador!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Panel de administración del sistema de horarios y ubicación de salones UPT',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Título del mapa administrativo
              const Row(
                children: [
                  Icon(Icons.location_on, color: Color(0xFF3B82F6)),
                  SizedBox(width: 12),
                  Text(
                    'Gestión de Salones - Piso 3',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Widget del mapa para administrador
              Container(height: 450, child: const MapWidget()),
              const SizedBox(height: 24),

              // Funciones administrativas
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.settings, color: Color(0xFF3B82F6)),
                        SizedBox(width: 12),
                        Text(
                          'Herramientas Administrativas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Botón de Gestión de Salones
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AdminSalonScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.business, color: Colors.white),
                        label: const Text(
                          'Gestión de Asignación de Salones',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Próximamente (otros botones)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🚀 Próximas Funciones',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Reportes de ocupación de salones\n• Configuración avanzada de aulas\n• Estadísticas de uso por periodo\n• Gestión de horarios especiales',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
