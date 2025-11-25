import 'package:flutter/material.dart';

void main() {
  runApp(const UniversityMapApp());
}

class UniversityMapApp extends StatelessWidget {
  const UniversityMapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapa 3er Piso',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TransformationController _transformationController =
      TransformationController();
  Room? selectedRoom;

  final List<Room> rooms = [
    // escaleras
    Room(
      id: 'escaleras-4',
      name: 'Subida 4to piso',
      position: const Offset(0, 500),
      size: const Size(100, 50),
      color: Colors.blue.shade100,
      description: 'Gradas',
    ),
    Room(
      id: 'escaleras-2',
      name: 'Bajada 2do piso',
      position: const Offset(0, 450),
      size: const Size(100, 50),
      color: Colors.blue.shade100,
      description: 'Gradas',
    ),
    Room(
      id: 'baños',
      name: '🚽S.S.H.H.🧻',
      position: const Offset(100, 550),
      size: const Size(100, 50),
      color: Colors.blue.shade100,
      description: 'Laboratorio',
    ),
    // Lado izquierdo
    Room(
      id: 'P-301',
      name: 'P-301',
      position: const Offset(50, 350),
      size: const Size(100, 100),
      color: Colors.blue.shade100,
      description: 'Laboratorio',
    ),
    Room(
      id: 'P-307',
      name: 'P-307',
      position: const Offset(150, 250),
      size: const Size(100, 100),
      color: Colors.green.shade100,
      description: 'Aula',
    ),
    Room(
      id: 'P-306',
      name: 'P-306',
      position: const Offset(200, 450),
      size: const Size(100, 100),
      color: Colors.orange.shade100,
      description: 'LAB. DE BASE DE DATOS',
    ),
    Room(
      id: 'P-310',
      name: 'P-310',
      position: const Offset(300, 350),
      size: const Size(100, 100),
      color: Colors.purple.shade100,
      description: 'LAB. DE DESARROLLO DE APLICACIONES',
    ),
    // Centro superior
    Room(
      id: 'P-311',
      name: 'P-311',
      position: const Offset(250, 150),
      size: const Size(100, 100),
      color: Colors.teal.shade100,
      description: 'LAB. DE REDES Y COMUNICACIÓN DE DATOS',
    ),
    Room(
      id: 'P-312A',
      name: 'P-312A',
      position: const Offset(350, 150),
      size: const Size(75, 50),
      color: Colors.cyan.shade100,
      description: 'SALA DE PROFESORES EPIS',
    ),
    Room(
      id: 'P-312B',
      name: 'P-312B',
      position: const Offset(425, 150),
      size: const Size(75, 50),
      color: Colors.cyan.shade100,
      description: 'Dirección',
    ),
    Room(
      id: 'gradas-ba',
      name: 'Bajar Gradas',
      position: const Offset(500, 200),
      size: const Size(50, 150),
      color: Colors.cyan.shade100,
      description: 'Bajar las gradas',
    ),
    Room(
      id: 'sala-descanso',
      name: '🎮',
      position: const Offset(400, 400),
      size: const Size(50, 25),
      color: Colors.cyan.shade100,
      description: 'Sala de Descanso',
    ),
    Room(
      id: 'cosas-perdidas',
      name: 'Cosas Perdidas',
      position: const Offset(400, 425),
      size: const Size(50, 25),
      color: Colors.cyan.shade100,
      description: 'Cosas Perdidas',
    ),
    Room(
      id: 'elevador',
      name: 'Elevador',
      position: const Offset(450, 350),
      size: const Size(50, 50),
      color: Colors.cyan.shade100,
      description: 'Elevador',
    ),
    Room(
      id: 'Q-301A',
      name: 'Q-301A',
      position: const Offset(500, 150),
      size: const Size(75, 50),
      color: Colors.cyan.shade100,
      description: 'DIRECCIÓN DE EPIE',
    ),
    Room(
      id: 'Q-301B',
      name: 'Q-301B',
      position: const Offset(575, 150),
      size: const Size(75, 50),
      color: Colors.cyan.shade100,
      description: 'SALA DE PROFESORES EPIE',
    ),
    Room(
      id: 'Q-303',
      name: 'Q-303',
      position: const Offset(650, 150),
      size: const Size(100, 100),
      color: Colors.cyan.shade100,
      description: 'LAB. DE CONTROL Y AUTOMATIZACIÓN',
    ),
    Room(
      id: 'Q-302',
      name: 'Q-302',
      position: const Offset(550, 350),
      size: const Size(100, 100),
      color: Colors.purple.shade100,
      description: 'LAB. DE LENGUAJE DE PROGRAMACIÓN',
    ),
    Room(
      id: 'Q-307',
      name: 'Q-307',
      position: const Offset(750, 250),
      size: const Size(100, 100),
      color: Colors.green.shade100,
      description: 'Aula',
    ),
    Room(
      id: 'Q-312',
      name: 'Q-312',
      position: const Offset(850, 350),
      size: const Size(100, 100),
      color: Colors.blue.shade100,
      description: 'Laboratorio',
    ),
    Room(
      id: 'Q-306',
      name: 'Q-306',
      position: const Offset(650, 450),
      size: const Size(100, 100),
      color: Colors.orange.shade100,
      description: 'LAB. DE DESARROLLO WEB',
    ),
    Room(
      id: 'baños',
      name: '🚽S.S.H.H.🧻',
      position: const Offset(750, 550),
      size: const Size(100, 50),
      color: Colors.blue.shade100,
      description: 'baños',
    ),
    Room(
      id: 'R-301',
      name: 'R-301',
      position: const Offset(950, 350),
      size: const Size(100, 100),
      color: Colors.blue.shade100,
      description: 'Laboratorio',
    ),
    Room(
      id: 'R-303',
      name: 'R-303',
      position: const Offset(1000, 250),
      size: const Size(100, 100),
      color: Colors.blue.shade100,
      description: 'Laboratorio',
    ),
    Room(
      id: 'R-306',
      name: 'R-306',
      position: const Offset(1150, 300),
      size: const Size(100, 100),
      color: Colors.blue.shade100,
      description: 'LAB. DE COMPUTO',
    ),
    Room(
      id: 'R-308',
      name: 'R-308',
      position: const Offset(1000, 150),
      size: const Size(100, 100),
      color: Colors.blue.shade100,
      description: 'Laboratorio',
    ),
    Room(
      id: 'R-307',
      name: 'R-307',
      position: const Offset(1150, 200),
      size: const Size(100, 100),
      color: Colors.blue.shade100,
      description: 'LAB. DE COMPUTO',
    ),
    Room(
      id: 'baños',
      name: '🚽S.S.H.H.🧻',
      position: const Offset(1150, 150),
      size: const Size(100, 50),
      color: Colors.blue.shade100,
      description: 'baños',
    ),
    Room(
      id: 'R-302',
      name: 'R-302',
      position: const Offset(1100, 400),
      size: const Size(150, 100),
      color: Colors.orange.shade100,
      description: 'LAB. DE BIOLOGÍA Y MICROBIOLOGÍA',
    ),
    Room(
      id: 'sala-descanso',
      name: '🎮',
      position: const Offset(1100, 500),
      size: const Size(150, 100),
      color: Colors.cyan.shade100,
      description: 'Sala de Descanso',
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
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: const Text('Ubicación'),
              subtitle: const Text('Tercer Piso'),
              contentPadding: EdgeInsets.zero,
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Mapa 3er Piso'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            onPressed: _resetZoom,
            tooltip: 'Resetear Zoom',
          ),
        ],
      ),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(1000),
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Container(
                width: 2300,
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: FloorMapPainter(
                    rooms: rooms,
                    selectedRoom: selectedRoom,
                    onRoomTap: _onRoomTap,
                  ),
                  child: GestureDetector(
                    onTapUp: (details) {
                      final RenderBox box =
                          context.findRenderObject() as RenderBox;
                      final localPosition = box.globalToLocal(
                        details.globalPosition,
                      );

                      for (var room in rooms) {
                        final rect = Rect.fromLTWH(
                          room.position.dx,
                          room.position.dy,
                          room.size.width,
                          room.size.height,
                        );
                        if (rect.contains(localPosition)) {
                          _onRoomTap(room);
                          break;
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Leyenda',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _legendItem(Colors.blue.shade100, 'Laboratorios'),
                    _legendItem(Colors.green.shade100, 'Aulas'),
                    _legendItem(Colors.purple.shade100, 'Oficinas'),
                    const SizedBox(height: 8),
                    const Text(
                      '👆 Toca un salón\npara ver detalles',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class FloorMapPainter extends CustomPainter {
  final List<Room> rooms;
  final Room? selectedRoom;
  final Function(Room) onRoomTap;

  FloorMapPainter({
    required this.rooms,
    required this.selectedRoom,
    required this.onRoomTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar pasillos/fondo
    final corridorPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;

    // Pasillo central horizontal
    canvas.drawRect(Rect.fromLTWH(200, 280, 600, 80), corridorPaint);

    // Pasillo central vertical
    canvas.drawRect(Rect.fromLTWH(400, 180, 100, 400), corridorPaint);

    // Dibujar salones
    for (var room in rooms) {
      final isSelected = selectedRoom?.id == room.id;

      final roomPaint = Paint()
        ..color = room.color
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = isSelected ? Colors.blue.shade700 : Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 3 : 1.5;

      final rect = Rect.fromLTWH(
        room.position.dx,
        room.position.dy,
        room.size.width,
        room.size.height,
      );

      // Sombra si está seleccionado
      if (isSelected) {
        final shadowPaint = Paint()
          ..color = Colors.blue.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          shadowPaint,
        );
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        roomPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        borderPaint,
      );

      // Dibujar texto del nombre
      final textPainter = TextPainter(
        text: TextSpan(
          text: room.name,
          style: TextStyle(
            color: Colors.black87,
            fontSize: isSelected ? 16 : 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          room.position.dx + (room.size.width - textPainter.width) / 2,
          room.position.dy + (room.size.height - textPainter.height) / 2,
        ),
      );

      // Icono de puerta
      final doorPaint = Paint()
        ..color = Colors.brown.shade400
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(
          room.position.dx + room.size.width / 2 - 3,
          room.position.dy,
          6,
          12,
        ),
        doorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FloorMapPainter oldDelegate) {
    return selectedRoom != oldDelegate.selectedRoom;
  }
}
