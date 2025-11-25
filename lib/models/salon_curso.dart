import 'package:cloud_firestore/cloud_firestore.dart';

class SalonCurso {
  final String id;
  final String codigoCurso;
  final String nombreCurso;
  final String codigoSalon;
  final String dia;
  final String horaInicio;
  final String horaFin;
  final String seccion;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;

  SalonCurso({
    required this.id,
    required this.codigoCurso,
    required this.nombreCurso,
    required this.codigoSalon,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.seccion,
    required this.fechaCreacion,
    required this.fechaModificacion,
  });

  // Constructor desde Map (para Firebase)
  factory SalonCurso.fromMap(Map<String, dynamic> map, String documentId) {
    return SalonCurso(
      id: documentId,
      codigoCurso: map['codigoCurso'] ?? '',
      nombreCurso: map['nombreCurso'] ?? '',
      codigoSalon: map['codigoSalon'] ?? '',
      dia: map['dia'] ?? '',
      horaInicio: map['horaInicio'] ?? '',
      horaFin: map['horaFin'] ?? '',
      seccion: map['seccion'] ?? '',
      fechaCreacion:
          (map['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaModificacion:
          (map['fechaModificacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Constructor desde DocumentSnapshot
  factory SalonCurso.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SalonCurso.fromMap(data, doc.id);
  }

  // Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'codigoCurso': codigoCurso,
      'nombreCurso': nombreCurso,
      'codigoSalon': codigoSalon,
      'dia': dia,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'seccion': seccion,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaModificacion': Timestamp.fromDate(fechaModificacion),
    };
  }

  // Copiar con modificaciones
  SalonCurso copyWith({
    String? codigoCurso,
    String? nombreCurso,
    String? codigoSalon,
    String? dia,
    String? horaInicio,
    String? horaFin,
    String? seccion,
  }) {
    return SalonCurso(
      id: id,
      codigoCurso: codigoCurso ?? this.codigoCurso,
      nombreCurso: nombreCurso ?? this.nombreCurso,
      codigoSalon: codigoSalon ?? this.codigoSalon,
      dia: dia ?? this.dia,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      seccion: seccion ?? this.seccion,
      fechaCreacion: fechaCreacion,
      fechaModificacion: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'SalonCurso(codigoCurso: $codigoCurso, salon: $codigoSalon, dia: $dia, hora: $horaInicio-$horaFin)';
  }
}

// Clase para estadísticas y resumen
class ResumenSalonCursos {
  final int totalAsignaciones;
  final int totalCursos;
  final int totalSalones;
  final Map<String, int> asignacionesPorDia;
  final Map<String, int> asignacionesPorSalon;

  ResumenSalonCursos({
    required this.totalAsignaciones,
    required this.totalCursos,
    required this.totalSalones,
    required this.asignacionesPorDia,
    required this.asignacionesPorSalon,
  });
}
