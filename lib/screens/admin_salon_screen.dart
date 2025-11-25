import 'package:flutter/material.dart';
import '../models/salon_curso.dart';
import '../services/salon_curso_service.dart';

class AdminSalonScreen extends StatefulWidget {
  const AdminSalonScreen({super.key});

  @override
  State<AdminSalonScreen> createState() => _AdminSalonScreenState();
}

class _AdminSalonScreenState extends State<AdminSalonScreen> {
  final SalonCursoService _salonService = SalonCursoService();
  List<SalonCurso> asignaciones = [];
  ResumenSalonCursos? resumen;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => isLoading = true);

    asignaciones = await _salonService.obtenerAsignaciones();
    resumen = await _salonService.obtenerResumen();

    setState(() => isLoading = false);
  }

  Future<void> _descargarFormato() async {
    setState(() => isLoading = true);

    Map<String, dynamic> resultado = await _salonService
        .descargarFormatoExcel();

    setState(() => isLoading = false);

    if (resultado['success']) {
      _mostrarDialogoExito(resultado['filePath']);
    } else {
      _mostrarMensaje('❌ ${resultado['message']}', Colors.red);
    }
  }

  void _mostrarDialogoExito(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Descarga Exitosa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('El formato Excel ha sido descargado correctamente.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Archivo guardado en:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filePath,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '📝 Llena el archivo con los datos de tus cursos y salones, luego usa el botón "Subir Archivo" para importar los datos.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _subirArchivo() async {
    setState(() => isLoading = true);

    try {
      Map<String, dynamic> resultado = await _salonService.subirArchivoExcel();

      setState(() => isLoading = false);

      if (resultado['success']) {
        List<SalonCurso> nuevasAsignaciones =
            resultado['data'] as List<SalonCurso>;
        List<String> errores = resultado['errores'] ?? [];

        // Mostrar diálogo de confirmación
        _mostrarDialogoConfirmacion(nuevasAsignaciones, errores);
      } else {
        _mostrarMensaje('❌ ${resultado['message']}', Colors.red);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _mostrarMensaje('❌ Error al procesar archivo: $e', Colors.red);
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _mostrarDialogoConfirmacion(
    List<SalonCurso> nuevasAsignaciones,
    List<String> errores,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📋 Confirmación de Importación'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '📊 Registros encontrados: ${nuevasAsignaciones.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              if (errores.isNotEmpty) ...[
                Text(
                  '⚠️ Errores encontrados: ${errores.length}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: errores.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '• ${errores[index]}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const Text(
                '⚠️ Esta acción reemplazará TODAS las asignaciones existentes.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              const Text('¿Desea continuar?', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmarGuardado(nuevasAsignaciones);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarGuardado(List<SalonCurso> nuevasAsignaciones) async {
    setState(() => isLoading = true);

    try {
      // Primero limpiar asignaciones existentes
      await _salonService.limpiarAsignaciones();

      // Guardar nuevas asignaciones
      Map<String, dynamic> resultado = await _salonService.guardarEnFirebase(
        nuevasAsignaciones,
      );

      if (resultado['success']) {
        _mostrarMensaje('✅ ${resultado['message']}', Colors.green);
        await _cargarDatos(); // Recargar datos
      } else {
        _mostrarMensaje('❌ ${resultado['message']}', Colors.red);
      }
    } catch (e) {
      _mostrarMensaje('❌ Error al guardar: $e', Colors.red);
    }

    setState(() => isLoading = false);
  }

  Future<void> _limpiarAsignaciones() async {
    // Mostrar diálogo de confirmación
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar Limpieza'),
        content: const Text(
          '¿Está seguro de que desea eliminar TODAS las asignaciones?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar Todo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => isLoading = true);

      bool resultado = await _salonService.limpiarAsignaciones();

      if (resultado) {
        _mostrarMensaje(
          '✅ Todas las asignaciones han sido eliminadas',
          Colors.green,
        );
        await _cargarDatos();
      } else {
        _mostrarMensaje('❌ Error al limpiar asignaciones', Colors.red);
      }

      setState(() => isLoading = false);
    }
  }

  Future<void> _eliminarAsignacion(SalonCurso asignacion) async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar Eliminación'),
        content: Text(
          '¿Está seguro de que desea eliminar la asignación del curso ${asignacion.codigoCurso} en el salón ${asignacion.codigoSalon}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => isLoading = true);

      bool resultado = await _salonService.eliminarAsignacion(asignacion.id);

      if (resultado) {
        _mostrarMensaje('✅ Asignación eliminada correctamente', Colors.green);
        await _cargarDatos();
      } else {
        _mostrarMensaje('❌ Error al eliminar asignación', Colors.red);
      }

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏫 Gestión de Salones'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildAcciones(),
                    const SizedBox(height: 20),
                    _buildEstadisticas(),
                    const SizedBox(height: 20),
                    _buildListaAsignaciones(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📚 Sistema de Asignación de Salones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Administra las asignaciones de salones a cursos mediante archivos Excel',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                '${asignaciones.length} asignaciones registradas',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔧 Acciones Principales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _descargarFormato,
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text(
                  'Descargar Formato',
                  style: TextStyle(color: Colors.white),
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
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _subirArchivo,
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: const Text(
                  'Subir Archivo',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (asignaciones.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _limpiarAsignaciones,
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              label: const Text(
                'Limpiar Todas las Asignaciones',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEstadisticas() {
    if (resumen == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 Estadísticas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildEstadisticaItem(
                  'Asignaciones',
                  '${resumen!.totalAsignaciones}',
                  const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEstadisticaItem(
                  'Cursos',
                  '${resumen!.totalCursos}',
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEstadisticaItem(
                  'Salones',
                  '${resumen!.totalSalones}',
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEstadisticaItem(String titulo, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListaAsignaciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📋 Asignaciones Actuales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
          ),
        ),
        const SizedBox(height: 12),

        if (asignaciones.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Column(
              children: [
                Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay asignaciones registradas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Descarga el formato Excel, llénalo y súbelo para comenzar',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: asignaciones.length,
            itemBuilder: (context, index) {
              SalonCurso asignacion = asignaciones[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asignacion.codigoCurso,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                              if (asignacion.nombreCurso.isNotEmpty)
                                Text(
                                  asignacion.nombreCurso,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _eliminarAsignacion(asignacion),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Eliminar asignación',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetalleItem(
                            '🏫 Salón',
                            asignacion.codigoSalon,
                            const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetalleItem(
                            '📅 Día',
                            asignacion.dia,
                            const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetalleItem(
                            '🕐 Inicio',
                            asignacion.horaInicio,
                            const Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetalleItem(
                            '🕑 Fin',
                            asignacion.horaFin,
                            const Color(0xFFEF4444),
                          ),
                        ),
                        if (asignacion.seccion.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDetalleItem(
                              '📚 Sección',
                              asignacion.seccion,
                              const Color(0xFF8B5CF6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildDetalleItem(String label, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
