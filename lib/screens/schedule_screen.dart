import 'package:flutter/material.dart';
import '../services/upt_service.dart';
import '../services/salon_curso_service.dart';
import '../models/course.dart';
import '../widgets/map_widget.dart';

class ScheduleScreen extends StatefulWidget {
  final UptService service;

  const ScheduleScreen({super.key, required this.service});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Course> _courses = [];
  List<SalonEstudiante> _salonesHoy = [];
  bool _isLoading = true;
  final SalonCursoService _salonService = SalonCursoService();

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      final courses = await widget.service.getSchedule();

      // Extraer códigos de cursos para buscar salones
      List<String> codigosCursos = courses
          .map((course) => course.codigo)
          .toList();

      // Obtener salones del día actual
      final salonesHoy = await _salonService.obtenerSalonesEstudiante(
        codigosCursos,
      );

      setState(() {
        _courses = courses;
        _salonesHoy = salonesHoy;
        _isLoading = false;
      });

      print('🎯 Salones encontrados para hoy: ${_salonesHoy.length}');
      for (var salon in _salonesHoy) {
        print('   ${salon.toString()}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar horario: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Dónde mi Salón?'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadSchedule();
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
          ? const Center(
              child: Text(
                'No se encontraron cursos',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de horarios
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.schedule, color: Color(0xFF3B82F6)),
                          SizedBox(width: 12),
                          Text(
                            'Mi Horario Académico',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tabla de horarios
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildScheduleTable(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Título del mapa
                    const Row(
                      children: [
                        Icon(Icons.map, color: Color(0xFF3B82F6)),
                        SizedBox(width: 12),
                        Text(
                          'Ubicación de Salones',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Información de salones del día
                    if (_salonesHoy.isNotEmpty) ...[
                      _buildSalonesInfo(),
                      const SizedBox(height: 16),
                    ],

                    // Widget del mapa con salones resaltados
                    MapWidget(
                      salonesEstudiante: _salonesHoy
                          .map((s) => s.codigoSalon)
                          .toList(),
                      salonActual: _salonesHoy.where((s) => s.esActual).isEmpty
                          ? null
                          : _salonesHoy
                                .firstWhere((s) => s.esActual)
                                .codigoSalon,
                      salonProximo:
                          _salonesHoy.where((s) => s.esProximo).isEmpty
                          ? null
                          : _salonesHoy
                                .firstWhere((s) => s.esProximo)
                                .codigoSalon,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildScheduleTable() {
    final days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    return DataTable(
      columnSpacing: 8,
      horizontalMargin: 8,
      columns: [
        const DataColumn(label: Text('Código')),
        const DataColumn(label: Text('Curso')),
        const DataColumn(label: Text('Sección')),
        ...days.map((day) => DataColumn(label: Text(day))),
      ],
      rows: _courses.map((course) {
        return DataRow(
          cells: [
            DataCell(Text(course.codigo)),
            DataCell(
              SizedBox(
                width: 150,
                child: Text(
                  course.nombre,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataCell(Text(course.seccion)),
            ...days.map((day) {
              final schedule = course.horarios[day.toLowerCase()];
              return DataCell(
                schedule != null
                    ? Text(
                        schedule,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      )
                    : const Text(''),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSalonesInfo() {
    String diaHoy = _obtenerNombreDiaHoy();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '📍 Tus Salones de Hoy ($diaHoy)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_salonesHoy.isEmpty)
            const Text(
              'No tienes clases programadas para hoy 🎉',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            )
          else
            Column(
              children: _salonesHoy.map((salon) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: salon.esActual
                        ? const Color(0xFF10B981).withOpacity(0.9)
                        : salon.esProximo
                        ? const Color(0xFFF59E0B).withOpacity(0.9)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: salon.esActual || salon.esProximo
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 40,
                        decoration: BoxDecoration(
                          color: salon.esActual
                              ? const Color(0xFF059669)
                              : salon.esProximo
                              ? const Color(0xFFD97706)
                              : const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  salon.codigoSalon,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: salon.esActual || salon.esProximo
                                        ? Colors.white
                                        : Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (salon.esActual)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF059669),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'AHORA',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else if (salon.esProximo)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD97706),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'PRÓXIMO',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${salon.codigoCurso} - ${salon.horaInicio} a ${salon.horaFin}',
                              style: TextStyle(
                                fontSize: 12,
                                color: salon.esActual || salon.esProximo
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.white70,
                              ),
                            ),
                            if (salon.nombreCurso.isNotEmpty)
                              Text(
                                salon.nombreCurso,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: salon.esActual || salon.esProximo
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.white60,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white70, size: 16),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Los salones aparecen resaltados en el mapa de abajo',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _obtenerNombreDiaHoy() {
    DateTime now = DateTime.now();
    List<String> diasSemana = [
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
    ];
    return diasSemana[now.weekday % 7];
  }
}
