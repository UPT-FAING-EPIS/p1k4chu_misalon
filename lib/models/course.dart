class Course {
  final String codigo;
  final String nombre;
  final String seccion;
  final Map<String, String> horarios;

  Course({
    required this.codigo,
    required this.nombre,
    required this.seccion,
    required this.horarios,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      codigo: map['codigo'] ?? '',
      nombre: map['nombre'] ?? '',
      seccion: map['seccion'] ?? '',
      horarios: Map<String, String>.from(map['horarios'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'seccion': seccion,
      'horarios': horarios,
    };
  }

  @override
  String toString() {
    return 'Course(codigo: $codigo, nombre: $nombre, seccion: $seccion, horarios: $horarios)';
  }
}
