import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class Room {
  final String id;
  final String name;
  final Offset position;
  final Size size;
  final Color color;
  final String? description;

  Room({
    required this.id,
    required this.name,
    required this.position,
    required this.size,
    required this.color,
    this.description,
  });
}

class MapWidget extends StatefulWidget {
  final List<String>? salonesEstudiante;
  final String? salonActual;
  final String? salonProximo;

  const MapWidget({
    super.key,
    this.salonesEstudiante,
    this.salonActual,
    this.salonProximo,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final TransformationController _transformationController =
      TransformationController();
  Room? selectedRoom;
  bool isLegendExpanded = false;

  final List<Room> rooms = [
    // Escaleras y accesos
    Room(
      id: 'escaleras-4',
      name: '⬆️ Subida 4to piso',
      position: const Offset(20, 500),
      size: const Size(120, 50),
      color: const Color(0xFFBBDEFB),
      description: 'Gradas al 4to piso',
    ),
    Room(
      id: 'escaleras-2',
      name: '⬇️ Bajada 2do piso',
      position: const Offset(20, 450),
      size: const Size(120, 50),
      color: const Color(0xFFBBDEFB),
      description: 'Gradas al 2do piso',
    ),
    Room(
      id: 'escaleras-4-2',
      name: '⬆️ Subida 4to piso',
      position: const Offset(900, 500),
      size: const Size(120, 50),
      color: const Color(0xFFBBDEFB),
      description: 'Gradas al 4to piso',
    ),
    Room(
      id: 'escaleras-2-2',
      name: '⬇️ Bajada 2do piso',
      position: const Offset(900, 450),
      size: const Size(120, 50),
      color: const Color(0xFFBBDEFB),
      description: 'Gradas al 2do piso',
    ),
    Room(
      id: 'gradas-ba',
      name: 'Bajar Gradas',
      position: const Offset(500, 200),
      size: const Size(50, 150),
      color: const Color(0xFFE3F2FD),
      description: 'Bajar las gradas',
    ),
    Room(
      id: 'elevador',
      name: '🏢 Elevador',
      position: const Offset(450, 350),
      size: const Size(80, 60),
      color: const Color(0xFFFFD54F),
      description: 'Elevador',
    ),

    // Servicios higiénicos
    Room(
      id: 'baños-1',
      name: '🚽S.S.H.H.🧻',
      position: const Offset(100, 550),
      size: const Size(100, 50),
      color: const Color(0xFFF3E5F5),
      description: 'Servicios Higiénicos',
    ),
    Room(
      id: 'baños-2',
      name: '🚽S.S.H.H.🧻',
      position: const Offset(750, 550),
      size: const Size(100, 50),
      color: const Color(0xFFF3E5F5),
      description: 'Servicios Higiénicos',
    ),
    Room(
      id: 'baños-3',
      name: '🚽S.S.H.H.🧻',
      position: const Offset(1150, 150),
      size: const Size(100, 50),
      color: const Color(0xFFF3E5F5),
      description: 'Servicios Higiénicos',
    ),

    // Salas de descanso y servicios
    Room(
      id: 'sala-descanso-1',
      name: '🎮',
      position: const Offset(400, 400),
      size: const Size(50, 25),
      color: const Color(0xFFF8BBD9),
      description: 'Sala de Descanso',
    ),
    Room(
      id: 'sala-descanso-2',
      name: '🎮',
      position: const Offset(1100, 500),
      size: const Size(150, 100),
      color: const Color(0xFFF8BBD9),
      description: 'Sala de Descanso',
    ),
    Room(
      id: 'cosas-perdidas',
      name: 'Cosas Perdidas',
      position: const Offset(400, 425),
      size: const Size(50, 25),
      color: const Color(0xFFE1BEE7),
      description: 'Objetos Perdidos',
    ),

    // Lado izquierdo - Laboratorios P
    Room(
      id: 'P-301',
      name: 'P-301',
      position: const Offset(50, 350),
      size: const Size(100, 100),
      color: const Color(0xFF90CAF9),
      description: 'Laboratorio',
    ),
    Room(
      id: 'P-306',
      name: 'P-306',
      position: const Offset(200, 450),
      size: const Size(100, 100),
      color: const Color(0xFFFFCC80),
      description: 'LAB. DE BASE DE DATOS',
    ),
    Room(
      id: 'P-307',
      name: 'P-307',
      position: const Offset(150, 250),
      size: const Size(100, 100),
      color: const Color(0xFFA5D6A7),
      description: 'Aula',
    ),
    Room(
      id: 'P-310',
      name: 'P-310',
      position: const Offset(300, 350),
      size: const Size(100, 100),
      color: const Color(0xFFCE93D8),
      description: 'LAB. DE DESARROLLO DE APLICACIONES',
    ),
    Room(
      id: 'P-311',
      name: 'P-311',
      position: const Offset(250, 150),
      size: const Size(100, 100),
      color: const Color(0xFF80CBC4),
      description: 'LAB. DE REDES Y COMUNICACIÓN DE DATOS',
    ),

    // Oficinas administrativas EPIS
    Room(
      id: 'P-312A',
      name: 'P-312A',
      position: const Offset(350, 150),
      size: const Size(75, 50),
      color: const Color(0xFF81D4FA),
      description: 'SALA DE PROFESORES EPIS',
    ),
    Room(
      id: 'P-312B',
      name: 'P-312B',
      position: const Offset(425, 150),
      size: const Size(75, 50),
      color: const Color(0xFF81D4FA),
      description: 'Dirección EPIS',
    ),

    // Centro - Laboratorios Q
    Room(
      id: 'Q-301A',
      name: 'Q-301A',
      position: const Offset(500, 150),
      size: const Size(75, 50),
      color: const Color(0xFF81D4FA),
      description: 'DIRECCIÓN DE EPIE',
    ),
    Room(
      id: 'Q-301B',
      name: 'Q-301B',
      position: const Offset(575, 150),
      size: const Size(75, 50),
      color: const Color(0xFF81D4FA),
      description: 'SALA DE PROFESORES EPIE',
    ),
    Room(
      id: 'Q-302',
      name: 'Q-302',
      position: const Offset(550, 350),
      size: const Size(100, 100),
      color: const Color(0xFFCE93D8),
      description: 'LAB. DE LENGUAJE DE PROGRAMACIÓN',
    ),
    Room(
      id: 'Q-303',
      name: 'Q-303',
      position: const Offset(650, 150),
      size: const Size(100, 100),
      color: const Color(0xFF80CBC4),
      description: 'LAB. DE CONTROL Y AUTOMATIZACIÓN',
    ),
    Room(
      id: 'Q-306',
      name: 'Q-306',
      position: const Offset(650, 450),
      size: const Size(100, 100),
      color: const Color(0xFFFFCC80),
      description: 'LAB. DE DESARROLLO WEB',
    ),
    Room(
      id: 'Q-307',
      name: 'Q-307',
      position: const Offset(750, 250),
      size: const Size(100, 100),
      color: const Color(0xFFA5D6A7),
      description: 'Aula',
    ),
    Room(
      id: 'Q-312',
      name: 'Q-312',
      position: const Offset(850, 350),
      size: const Size(100, 100),
      color: const Color(0xFF90CAF9),
      description: 'Laboratorio',
    ),

    // Lado derecho - Laboratorios R
    Room(
      id: 'R-301',
      name: 'R-301',
      position: const Offset(950, 350),
      size: const Size(100, 100),
      color: const Color(0xFF90CAF9),
      description: 'Laboratorio',
    ),
    Room(
      id: 'R-302',
      name: 'R-302',
      position: const Offset(1100, 400),
      size: const Size(150, 100),
      color: const Color(0xFFFFCC80),
      description: 'LAB. DE BIOLOGÍA Y MICROBIOLOGÍA',
    ),
    Room(
      id: 'R-303',
      name: 'R-303',
      position: const Offset(1000, 250),
      size: const Size(100, 100),
      color: const Color(0xFF90CAF9),
      description: 'Laboratorio',
    ),
    Room(
      id: 'R-306',
      name: 'R-306',
      position: const Offset(1150, 300),
      size: const Size(100, 100),
      color: const Color(0xFF90CAF9),
      description: 'LAB. DE COMPUTO',
    ),
    Room(
      id: 'R-307',
      name: 'R-307',
      position: const Offset(1150, 200),
      size: const Size(100, 100),
      color: const Color(0xFF90CAF9),
      description: 'LAB. DE COMPUTO',
    ),
    Room(
      id: 'R-308',
      name: 'R-308',
      position: const Offset(1000, 150),
      size: const Size(100, 100),
      color: const Color(0xFF90CAF9),
      description: 'Laboratorio',
    ),
  ];

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _onRoomTap(Room room) {
    setState(() {
      selectedRoom = room;
    });
    _showRoomDetails(room);
  }

  void _showRoomDetails(Room room) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: room.color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                      Text(
                        room.description ?? 'Salón',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFF3B82F6)),
              title: const Text('Ubicación'),
              subtitle: const Text('Tercer Piso - Pabellón Principal UPT'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _openFullScreenMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenMapScreen(rooms: rooms),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🗺️ Mapa del 3er Piso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                      onPressed: () => _openFullScreenMap(context),
                      tooltip: 'Ver en pantalla completa',
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_out_map, color: Colors.white),
                      onPressed: _resetZoom,
                      tooltip: 'Resetear Zoom',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    boundaryMargin: const EdgeInsets.all(50),
                    minScale: 0.2,
                    maxScale: 5.0,
                    constrained: false,
                    child: Container(
                      width: 1400,
                      height: 700,
                      color: const Color(0xFFF8FAFC),
                      child: GestureDetector(
                        onTapUp: (details) {
                          final RenderBox box =
                              context.findRenderObject() as RenderBox;
                          final Offset localPosition = box.globalToLocal(
                            details.globalPosition,
                          );

                          // Obtener la transformación actual
                          final Matrix4 transform =
                              _transformationController.value;
                          final Matrix4 invertedTransform = Matrix4.inverted(
                            transform,
                          );

                          // Convertir la posición local al sistema de coordenadas del canvas
                          final vm.Vector3 canvasPosition = invertedTransform
                              .transform3(
                                vm.Vector3(
                                  localPosition.dx,
                                  localPosition.dy,
                                  0,
                                ),
                              );
                          final Offset canvasOffset = Offset(
                            canvasPosition.x,
                            canvasPosition.y,
                          );

                          for (var room in rooms) {
                            final rect = Rect.fromLTWH(
                              room.position.dx,
                              room.position.dy,
                              room.size.width,
                              room.size.height,
                            );
                            if (rect.contains(canvasOffset)) {
                              _onRoomTap(room);
                              break;
                            }
                          }
                        },
                        child: CustomPaint(
                          painter: FloorMapPainter(
                            rooms: rooms,
                            selectedRoom: selectedRoom,
                            onRoomTap: _onRoomTap,
                            salonesEstudiante: widget.salonesEstudiante,
                            salonActual: widget.salonActual,
                            salonProximo: widget.salonProximo,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isLegendExpanded = !isLegendExpanded;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Leyenda',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLegendExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: const Color(0xFF1E40AF),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        if (isLegendExpanded) ...[
                          const SizedBox(height: 8),
                          _legendItem(const Color(0xFF90CAF9), 'Laboratorios'),
                          _legendItem(const Color(0xFFA5D6A7), 'Aulas'),
                          _legendItem(const Color(0xFFCE93D8), 'Programación'),
                          _legendItem(
                            const Color(0xFFFFCC80),
                            'Especializados',
                          ),
                          _legendItem(const Color(0xFF81D4FA), 'Oficinas'),
                          _legendItem(const Color(0xFFF8BBD9), 'Descanso'),
                          _legendItem(const Color(0xFFE3F2FD), 'Accesos'),
                          const SizedBox(height: 8),
                          const Text(
                            '👆 Toca un salón\npara ver detalles',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ] else ...[
                          const SizedBox(height: 4),
                          const Text(
                            '👆 Toca aquí para ver más',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class FloorMapPainter extends CustomPainter {
  final List<Room> rooms;
  final Room? selectedRoom;
  final Function(Room) onRoomTap;
  final List<String>? salonesEstudiante;
  final String? salonActual;
  final String? salonProximo;

  FloorMapPainter({
    required this.rooms,
    required this.selectedRoom,
    required this.onRoomTap,
    this.salonesEstudiante,
    this.salonActual,
    this.salonProximo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Marco principal simple que engloba todo
    final borderPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Dibujar marco principal del edificio
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 120, 1380, 550),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    // Título del piso en la parte superior
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: '3ER PISO - PABELLÓN PRINCIPAL UPT',
        style: TextStyle(
          color: Color(0xFF1E40AF),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, Offset((1400 - titlePainter.width) / 2, 90));

    // Dibujar salones
    for (var room in rooms) {
      final isSelected = selectedRoom?.id == room.id;
      final isSpecialAccess =
          room.id.contains('escaleras') || room.id == 'elevador';

      // Verificar si es salón del estudiante
      final esSalonEstudiante = salonesEstudiante?.contains(room.id) ?? false;
      final esSalonActual = salonActual == room.id;
      final esSalonProximo = salonProximo == room.id;

      Color roomColor = room.color;
      Color borderColor;
      double borderWidth;

      if (esSalonActual) {
        // Salón donde tiene clase ahora - Verde vibrante
        roomColor = const Color(0xFF10B981).withOpacity(0.8);
        borderColor = const Color(0xFF059669);
        borderWidth = 4;
      } else if (esSalonProximo) {
        // Próximo salón - Amarillo vibrante
        roomColor = const Color(0xFFF59E0B).withOpacity(0.8);
        borderColor = const Color(0xFFD97706);
        borderWidth = 4;
      } else if (esSalonEstudiante) {
        // Otros salones del día - Azul suave
        roomColor = const Color(0xFF3B82F6).withOpacity(0.6);
        borderColor = const Color(0xFF2563EB);
        borderWidth = 3;
      } else if (isSelected) {
        borderColor = const Color(0xFF3B82F6);
        borderWidth = 3;
      } else if (isSpecialAccess) {
        borderColor = const Color(0xFF1565C0);
        borderWidth = 3;
      } else {
        borderColor = const Color(0xFF94A3B8);
        borderWidth = 1.5;
      }

      final roomPaint = Paint()
        ..color = roomColor
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;

      final rect = Rect.fromLTWH(
        room.position.dx,
        room.position.dy,
        room.size.width,
        room.size.height,
      );

      // Efectos especiales para salones del estudiante
      if (esSalonActual) {
        // Glow verde para salón actual
        final glowPaint = Paint()
          ..color = const Color(0xFF10B981).withOpacity(0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(12)),
          glowPaint,
        );

        // Efecto de pulsación (segundo glow más grande)
        final pulsePaint = Paint()
          ..color = const Color(0xFF10B981).withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
        final expandedRect = Rect.fromLTWH(
          room.position.dx - 4,
          room.position.dy - 4,
          room.size.width + 8,
          room.size.height + 8,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(expandedRect, const Radius.circular(16)),
          pulsePaint,
        );
      } else if (esSalonProximo) {
        // Glow amarillo para próximo salón
        final glowPaint = Paint()
          ..color = const Color(0xFFF59E0B).withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(12)),
          glowPaint,
        );
      } else if (esSalonEstudiante) {
        // Glow azul suave para otros salones del día
        final glowPaint = Paint()
          ..color = const Color(0xFF3B82F6).withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(12)),
          glowPaint,
        );
      } else if (isSelected) {
        // Sombra si está seleccionado normalmente
        final shadowPaint = Paint()
          ..color = const Color(0xFF3B82F6).withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(12)),
          shadowPaint,
        );
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
        roomPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
        borderPaint,
      );

      // Dibujar texto del nombre
      final textPainter = TextPainter(
        text: TextSpan(
          text: room.name,
          style: TextStyle(
            color: isSpecialAccess
                ? const Color(0xFF0D47A1)
                : const Color(0xFF1E293B),
            fontSize: isSelected ? 14 : (isSpecialAccess ? 11 : 12),
            fontWeight: isSelected
                ? FontWeight.bold
                : (isSpecialAccess ? FontWeight.bold : FontWeight.w600),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      if (textPainter.width <= room.size.width - 8 &&
          textPainter.height <= room.size.height - 8) {
        textPainter.paint(
          canvas,
          Offset(
            room.position.dx + (room.size.width - textPainter.width) / 2,
            room.position.dy + (room.size.height - textPainter.height) / 2,
          ),
        );
      }

      // Icono de puerta
      final doorPaint = Paint()
        ..color = const Color(0xFF8B5CF6)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            room.position.dx + room.size.width / 2 - 4,
            room.position.dy - 2,
            8,
            12,
          ),
          const Radius.circular(2),
        ),
        doorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FloorMapPainter oldDelegate) {
    return selectedRoom != oldDelegate.selectedRoom ||
        salonesEstudiante != oldDelegate.salonesEstudiante ||
        salonActual != oldDelegate.salonActual ||
        salonProximo != oldDelegate.salonProximo;
  }
}

// Pantalla de mapa en pantalla completa
class FullScreenMapScreen extends StatefulWidget {
  final List<Room> rooms;

  const FullScreenMapScreen({super.key, required this.rooms});

  @override
  State<FullScreenMapScreen> createState() => _FullScreenMapScreenState();
}

class _FullScreenMapScreenState extends State<FullScreenMapScreen> {
  final TransformationController _transformationController =
      TransformationController();
  Room? selectedRoom;
  bool isLegendExpanded = true;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _onRoomTap(Room room) {
    setState(() {
      selectedRoom = room;
    });
    _showRoomDetails(room);
  }

  void _showRoomDetails(Room room) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: room.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        room.description ?? 'Salón',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.location_on,
                color: Color(0xFF3B82F6),
                size: 28,
              ),
              title: const Text(
                'Ubicación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Tercer Piso - Pabellón Principal UPT',
                style: TextStyle(fontSize: 16),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          '🗺️ Mapa Completo - 3er Piso UPT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            onPressed: _resetZoom,
            tooltip: 'Resetear Zoom',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Cerrar',
          ),
        ],
      ),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(50),
            minScale: 0.2,
            maxScale: 5.0,
            constrained: false,
            child: Container(
              width: 1400,
              height: 700,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
                ),
              ),
              child: GestureDetector(
                onTapUp: (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final Offset localPosition = box.globalToLocal(
                    details.globalPosition,
                  );

                  // Obtener la transformación actual
                  final Matrix4 transform = _transformationController.value;
                  final Matrix4 invertedTransform = Matrix4.inverted(transform);

                  // Convertir la posición local al sistema de coordenadas del canvas
                  final vm.Vector3 canvasPosition = invertedTransform
                      .transform3(
                        vm.Vector3(localPosition.dx, localPosition.dy, 0),
                      );
                  final Offset canvasOffset = Offset(
                    canvasPosition.x,
                    canvasPosition.y,
                  );

                  for (var room in widget.rooms) {
                    final rect = Rect.fromLTWH(
                      room.position.dx,
                      room.position.dy,
                      room.size.width,
                      room.size.height,
                    );
                    if (rect.contains(canvasOffset)) {
                      _onRoomTap(room);
                      break;
                    }
                  }
                },
                child: CustomPaint(
                  painter: FloorMapPainter(
                    rooms: widget.rooms,
                    selectedRoom: selectedRoom,
                    onRoomTap: _onRoomTap,
                  ),
                ),
              ),
            ),
          ),

          // Leyenda colapsible mejorada para pantalla completa
          Positioned(
            top: 20,
            right: 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLegendExpanded = !isLegendExpanded;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Leyenda de Espacios',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLegendExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: const Color(0xFF1E40AF),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  if (isLegendExpanded) ...[
                    const SizedBox(height: 12),
                    _legendItem(const Color(0xFF90CAF9), 'Laboratorios'),
                    _legendItem(const Color(0xFFA5D6A7), 'Aulas'),
                    _legendItem(
                      const Color(0xFFCE93D8),
                      'Labs de Programación',
                    ),
                    _legendItem(const Color(0xFFFFCC80), 'Labs Especializados'),
                    _legendItem(const Color(0xFF80CBC4), 'Redes & Control'),
                    _legendItem(const Color(0xFF81D4FA), 'Oficinas'),
                    _legendItem(const Color(0xFFF8BBD9), 'Salas de Descanso'),
                    _legendItem(
                      const Color(0xFFF3E5F5),
                      'Servicios Higiénicos',
                    ),
                    _legendItem(const Color(0xFFE3F2FD), 'Escaleras & Accesos'),
                    const SizedBox(height: 12),
                    const Text(
                      '👆 Toca cualquier salón\npara ver información detallada',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Toca para expandir',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Instrucciones de navegación
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🔍 Navegación:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Pellizca para hacer zoom\n• Arrastra para moverte\n• Toca salones para info',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
