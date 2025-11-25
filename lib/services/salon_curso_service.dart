import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/salon_curso.dart';

class SalonCursoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collection = 'salon_cursos';

  // Generar formato Excel para descarga
  Future<Map<String, dynamic>> descargarFormatoExcel() async {
    try {
      // Crear archivo Excel
      var excel = Excel.createExcel();
      Sheet sheet = excel['Asignacion_Salones'];

      // Eliminar hoja por defecto
      excel.delete('Sheet1');

      // Crear encabezados
      List<String> headers = [
        'CODIGO_CURSO',
        'NOMBRE_CURSO',
        'CODIGO_SALON',
        'DIA',
        'HORA_INICIO',
        'HORA_FIN',
        'SECCION',
      ];

      // Agregar encabezados con formato
      for (int i = 0; i < headers.length; i++) {
        var cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue100,
          fontColorHex: ExcelColor.black,
        );
      }

      // Agregar filas de ejemplo
      List<List<String>> ejemplos = [
        [
          'SI-881',
          'INTELIGENCIA ARTIFICIAL',
          'P-310',
          'LUNES',
          '15:00',
          '16:40',
          'A',
        ],
        [
          'SI-882',
          'REDES Y COMUNICACIÓN DE DATOS I',
          'Q-303',
          'MARTES',
          '18:20',
          '20:00',
          'A',
        ],
        [
          'SI-883',
          'SOLUCIONES MÓVILES I',
          'Q-302',
          'MIÉRCOLES',
          '16:40',
          '18:20',
          'A',
        ],
        ['', '', '', '', '', '', ''], // Fila vacía para que puedan agregar más
      ];

      for (int i = 0; i < ejemplos.length; i++) {
        for (int j = 0; j < ejemplos[i].length; j++) {
          var cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1),
          );
          cell.value = TextCellValue(ejemplos[i][j]);

          // Estilo para ejemplos (texto gris)
          if (ejemplos[i][j].isNotEmpty) {
            cell.cellStyle = CellStyle(
              fontColorHex: ExcelColor.black,
              italic: true,
            );
          }
        }
      }

      // Agregar instrucciones en una hoja separada
      Sheet instrucciones = excel['Instrucciones'];
      List<String> instruccionesList = [
        'INSTRUCCIONES PARA LLENAR EL FORMATO:',
        '',
        '1. CODIGO_CURSO: Código del curso (ej: SI-881, SI-882)',
        '2. NOMBRE_CURSO: Nombre completo del curso',
        '3. CODIGO_SALON: Código del salón donde se dicta (ej: P-310, Q-312)',
        '4. DIA: Día de la semana (LUNES, MARTES, MIÉRCOLES, JUEVES, VIERNES, SÁBADO, DOMINGO)',
        '5. HORA_INICIO: Hora de inicio en formato 24h (ej: 15:00)',
        '6. HORA_FIN: Hora de finalización en formato 24h (ej: 16:40)',
        '7. SECCION: Sección del curso (ej: A, B, C)',
        '',
        'NOTAS IMPORTANTES:',
        '• Un curso puede tener múltiples horarios (diferentes días/salones)',
        '• Todos los campos son obligatorios',
        '• Los días deben escribirse en MAYÚSCULAS',
        '• Use formato 24 horas para las horas (HH:MM)',
        '• Los códigos de salón deben coincidir con los del mapa',
        '',
        'SALONES DISPONIBLES EN EL 3ER PISO:',
        'P-301, P-306, P-307, P-310, P-311, P-312A, P-312B',
        'Q-301A, Q-301B, Q-302, Q-303, Q-306, Q-307, Q-312',
        'R-301, R-302, R-303, R-306, R-307, R-308',
      ];

      for (int i = 0; i < instruccionesList.length; i++) {
        var cell = instrucciones.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i),
        );
        cell.value = TextCellValue(instruccionesList[i]);

        if (i == 0) {
          // Título principal
          cell.cellStyle = CellStyle(
            bold: true,
            fontSize: 14,
            fontColorHex: ExcelColor.blue800,
          );
        } else if (instruccionesList[i].contains(':') &&
            !instruccionesList[i].startsWith(' ')) {
          // Subtítulos
          cell.cellStyle = CellStyle(
            bold: true,
            fontColorHex: ExcelColor.blue600,
          );
        }
      }

      // Guardar archivo
      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        // Usar FilePicker para que el usuario elija dónde guardar
        String? filePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Guardar formato Excel',
          fileName: 'formato_asignacion_salones.xlsx',
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
          bytes: Uint8List.fromList(fileBytes),
        );

        if (filePath != null) {
          print('✅ Archivo Excel guardado: $filePath');
          return {
            'success': true,
            'message': 'Formato Excel guardado exitosamente',
            'filePath': filePath,
          };
        } else {
          return {
            'success': false,
            'message': 'Guardado cancelado por el usuario',
            'filePath': '',
          };
        }
      }
      return {
        'success': false,
        'message': 'Error al generar archivo Excel',
        'filePath': '',
      };
    } catch (e) {
      print('❌ Error al generar Excel: $e');
      return {
        'success': false,
        'message': 'Error al generar Excel: $e',
        'filePath': '',
      };
    }
  }

  // Subir archivo Excel y procesar datos
  Future<Map<String, dynamic>> subirArchivoExcel() async {
    try {
      print('🔄 Iniciando selección de archivo Excel...');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null) {
        print('✅ Archivo seleccionado: ${result.files.single.name}');

        if (result.files.single.bytes != null) {
          print('📄 Procesando archivo desde bytes...');
          Uint8List bytes = result.files.single.bytes!;
          return await _procesarArchivoExcel(bytes);
        } else if (result.files.single.path != null) {
          print(
            '📄 Procesando archivo desde path: ${result.files.single.path}',
          );
          File file = File(result.files.single.path!);
          Uint8List bytes = await file.readAsBytes();
          return await _procesarArchivoExcel(bytes);
        } else {
          print('❌ No se pudo acceder al contenido del archivo');
          return {
            'success': false,
            'message':
                'No se pudo acceder al contenido del archivo seleccionado',
            'data': <SalonCurso>[],
          };
        }
      } else {
        print('❌ No se seleccionó ningún archivo');
        return {
          'success': false,
          'message': 'No se seleccionó ningún archivo',
          'data': <SalonCurso>[],
        };
      }
    } catch (e) {
      print('❌ Error en subirArchivoExcel: $e');
      return {
        'success': false,
        'message': 'Error al subir archivo: $e',
        'data': <SalonCurso>[],
      };
    }
  }

  // Procesar archivo Excel
  Future<Map<String, dynamic>> _procesarArchivoExcel(Uint8List bytes) async {
    try {
      print('📊 Iniciando procesamiento del archivo Excel...');
      print('📊 Tamaño del archivo: ${bytes.length} bytes');

      var excel = Excel.decodeBytes(bytes);
      List<SalonCurso> salonesCursos = [];
      List<String> errores = [];
      int filasProcesadas = 0;

      print('📊 Hojas encontradas: ${excel.tables.keys.toList()}');

      for (var table in excel.tables.keys) {
        if (table == 'Instrucciones') continue; // Saltar hoja de instrucciones

        print('📊 Procesando hoja: $table');
        var sheet = excel.tables[table];
        if (sheet == null) continue;

        print('📊 Filas en la hoja $table: ${sheet.maxRows}');

        // Procesar filas (empezar desde fila 1, saltando encabezados)
        for (int i = 1; i < sheet.maxRows; i++) {
          try {
            List<String> rowData = [];

            // Extraer datos de la fila
            for (int j = 0; j < 7; j++) {
              var cellData = sheet.cell(
                CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i),
              );
              rowData.add(cellData.value?.toString().trim() ?? '');
            }

            print('📄 Fila ${i + 1}: $rowData');

            // Saltar filas vacías
            if (rowData.every((element) => element.isEmpty)) {
              print('⏭️ Saltando fila vacía ${i + 1}');
              continue;
            }

            // Validar datos obligatorios
            if (rowData[0].isEmpty ||
                rowData[2].isEmpty ||
                rowData[3].isEmpty) {
              String error =
                  'Fila ${i + 1}: Campos obligatorios vacíos (Código Curso: "${rowData[0]}", Código Salón: "${rowData[2]}", Día: "${rowData[3]}")';
              print('❌ $error');
              errores.add(error);
              continue;
            }

            print('✅ Fila ${i + 1}: Datos válidos');

            // Crear objeto SalonCurso
            SalonCurso salonCurso = SalonCurso(
              id: '', // Se asignará al guardar en Firebase
              codigoCurso: rowData[0].toUpperCase(),
              nombreCurso: rowData[1],
              codigoSalon: rowData[2].toUpperCase(),
              dia: rowData[3].toUpperCase(),
              horaInicio: _formatearHora(rowData[4]),
              horaFin: _formatearHora(rowData[5]),
              seccion: rowData[6].toUpperCase(),
              fechaCreacion: DateTime.now(),
              fechaModificacion: DateTime.now(),
            );

            salonesCursos.add(salonCurso);
            filasProcesadas++;
          } catch (e) {
            errores.add('Fila ${i + 1}: Error al procesar datos - $e');
          }
        }
        break; // Solo procesar la primera hoja de datos
      }

      print('📊 Procesamiento completado:');
      print('   ✅ Registros válidos: $filasProcesadas');
      print('   ❌ Errores encontrados: ${errores.length}');
      print('   📄 Total de asignaciones creadas: ${salonesCursos.length}');

      return {
        'success': true,
        'message': 'Archivo procesado: $filasProcesadas registros válidos',
        'data': salonesCursos,
        'errores': errores,
        'filasProcesadas': filasProcesadas,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al procesar Excel: $e',
        'data': <SalonCurso>[],
      };
    }
  }

  // Formatear hora
  String _formatearHora(String hora) {
    if (hora.isEmpty) return '';

    // Si ya tiene formato correcto
    if (RegExp(r'^\d{2}:\d{2}$').hasMatch(hora)) {
      return hora;
    }

    // Intentar extraer hora de diferentes formatos
    var match = RegExp(r'(\d{1,2}):?(\d{2})?').firstMatch(hora);
    if (match != null) {
      int horas = int.parse(match.group(1) ?? '0');
      int minutos = int.parse(match.group(2) ?? '0');
      return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}';
    }

    return hora;
  }

  // Guardar datos en Firebase
  Future<Map<String, dynamic>> guardarEnFirebase(
    List<SalonCurso> salonesCursos,
  ) async {
    try {
      WriteBatch batch = _firestore.batch();
      int guardados = 0;

      for (SalonCurso salonCurso in salonesCursos) {
        DocumentReference docRef = _firestore.collection(collection).doc();
        batch.set(docRef, salonCurso.toMap());
        guardados++;
      }

      await batch.commit();

      return {
        'success': true,
        'message': 'Se guardaron $guardados asignaciones correctamente',
        'guardados': guardados,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al guardar en base de datos: $e',
        'guardados': 0,
      };
    }
  }

  // Obtener todas las asignaciones
  Future<List<SalonCurso>> obtenerAsignaciones() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .orderBy('fechaModificacion', descending: true)
          .get();

      return snapshot.docs.map((doc) => SalonCurso.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener asignaciones: $e');
      return [];
    }
  }

  // Eliminar todas las asignaciones
  Future<bool> limpiarAsignaciones() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(collection).get();
      WriteBatch batch = _firestore.batch();

      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error al limpiar asignaciones: $e');
      return false;
    }
  }

  // Eliminar asignación específica
  Future<bool> eliminarAsignacion(String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error al eliminar asignación: $e');
      return false;
    }
  }

  // Actualizar asignación
  Future<bool> actualizarAsignacion(SalonCurso salonCurso) async {
    try {
      await _firestore
          .collection(collection)
          .doc(salonCurso.id)
          .update(salonCurso.copyWith().toMap());
      return true;
    } catch (e) {
      print('Error al actualizar asignación: $e');
      return false;
    }
  }

  // Obtener resumen estadístico
  Future<ResumenSalonCursos> obtenerResumen() async {
    try {
      List<SalonCurso> asignaciones = await obtenerAsignaciones();

      Set<String> cursosUnicos = asignaciones.map((e) => e.codigoCurso).toSet();
      Set<String> salonesUnicos = asignaciones
          .map((e) => e.codigoSalon)
          .toSet();

      Map<String, int> asignacionesPorDia = {};
      Map<String, int> asignacionesPorSalon = {};

      for (SalonCurso asignacion in asignaciones) {
        asignacionesPorDia[asignacion.dia] =
            (asignacionesPorDia[asignacion.dia] ?? 0) + 1;
        asignacionesPorSalon[asignacion.codigoSalon] =
            (asignacionesPorSalon[asignacion.codigoSalon] ?? 0) + 1;
      }

      return ResumenSalonCursos(
        totalAsignaciones: asignaciones.length,
        totalCursos: cursosUnicos.length,
        totalSalones: salonesUnicos.length,
        asignacionesPorDia: asignacionesPorDia,
        asignacionesPorSalon: asignacionesPorSalon,
      );
    } catch (e) {
      print('Error al obtener resumen: $e');
      return ResumenSalonCursos(
        totalAsignaciones: 0,
        totalCursos: 0,
        totalSalones: 0,
        asignacionesPorDia: {},
        asignacionesPorSalon: {},
      );
    }
  }

  // Buscar salón por curso y horario
  Future<String?> buscarSalonPorCursoHorario(
    String codigoCurso,
    String dia,
    String hora,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .where('codigoCurso', isEqualTo: codigoCurso.toUpperCase())
          .where('dia', isEqualTo: dia.toUpperCase())
          .get();

      for (DocumentSnapshot doc in snapshot.docs) {
        SalonCurso asignacion = SalonCurso.fromFirestore(doc);

        // Verificar si la hora está en el rango
        if (_estaEnRangoHorario(
          hora,
          asignacion.horaInicio,
          asignacion.horaFin,
        )) {
          return asignacion.codigoSalon;
        }
      }

      return null;
    } catch (e) {
      print('Error al buscar salón: $e');
      return null;
    }
  }

  // Verificar si una hora está en el rango
  bool _estaEnRangoHorario(String hora, String inicio, String fin) {
    try {
      int horaMinutos = _convertirHoraAMinutos(hora);
      int inicioMinutos = _convertirHoraAMinutos(inicio);
      int finMinutos = _convertirHoraAMinutos(fin);

      return horaMinutos >= inicioMinutos && horaMinutos <= finMinutos;
    } catch (e) {
      return false;
    }
  }

  // Convertir hora a minutos
  int _convertirHoraAMinutos(String hora) {
    List<String> partes = hora.split(':');
    return int.parse(partes[0]) * 60 + int.parse(partes[1]);
  }

  // Obtener salones del estudiante para el día actual
  Future<List<SalonEstudiante>> obtenerSalonesEstudiante(
    List<String> codigosCursos,
  ) async {
    try {
      String diaActual = _obtenerDiaActual();
      List<SalonEstudiante> salonesEstudiante = [];

      for (String codigoCurso in codigosCursos) {
        QuerySnapshot snapshot = await _firestore
            .collection(collection)
            .where('codigoCurso', isEqualTo: codigoCurso.toUpperCase())
            .where('dia', isEqualTo: diaActual)
            .get();

        for (DocumentSnapshot doc in snapshot.docs) {
          SalonCurso asignacion = SalonCurso.fromFirestore(doc);

          salonesEstudiante.add(
            SalonEstudiante(
              codigoSalon: asignacion.codigoSalon,
              codigoCurso: asignacion.codigoCurso,
              nombreCurso: asignacion.nombreCurso,
              horaInicio: asignacion.horaInicio,
              horaFin: asignacion.horaFin,
              dia: asignacion.dia,
              esProximo: _esProximoCurso(asignacion.horaInicio),
              esActual: _esCursoActual(
                asignacion.horaInicio,
                asignacion.horaFin,
              ),
            ),
          );
        }
      }

      // Ordenar por hora de inicio
      salonesEstudiante.sort(
        (a, b) => _convertirHoraAMinutos(
          a.horaInicio,
        ).compareTo(_convertirHoraAMinutos(b.horaInicio)),
      );

      return salonesEstudiante;
    } catch (e) {
      print('Error al obtener salones del estudiante: $e');
      return [];
    }
  }

  // Obtener día actual en formato de base de datos
  String _obtenerDiaActual() {
    DateTime now = DateTime.now();
    List<String> diasSemana = [
      'DOMINGO',
      'LUNES',
      'MARTES',
      'MIÉRCOLES',
      'JUEVES',
      'VIERNES',
      'SÁBADO',
    ];
    return diasSemana[now.weekday % 7];
  }

  // Verificar si es el próximo curso (dentro de los próximos 30 minutos)
  bool _esProximoCurso(String horaInicio) {
    try {
      DateTime now = DateTime.now();
      int horaActualMinutos = now.hour * 60 + now.minute;
      int horaInicioMinutos = _convertirHoraAMinutos(horaInicio);

      // Próximo si falta entre 0 y 30 minutos
      int diferencia = horaInicioMinutos - horaActualMinutos;
      return diferencia > 0 && diferencia <= 30;
    } catch (e) {
      return false;
    }
  }

  // Verificar si es el curso actual (en progreso)
  bool _esCursoActual(String horaInicio, String horaFin) {
    try {
      DateTime now = DateTime.now();
      String horaActual =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      return _estaEnRangoHorario(horaActual, horaInicio, horaFin);
    } catch (e) {
      return false;
    }
  }
}

// Clase para representar salones del estudiante
class SalonEstudiante {
  final String codigoSalon;
  final String codigoCurso;
  final String nombreCurso;
  final String horaInicio;
  final String horaFin;
  final String dia;
  final bool esProximo;
  final bool esActual;

  SalonEstudiante({
    required this.codigoSalon,
    required this.codigoCurso,
    required this.nombreCurso,
    required this.horaInicio,
    required this.horaFin,
    required this.dia,
    required this.esProximo,
    required this.esActual,
  });

  @override
  String toString() {
    return 'SalonEstudiante{codigoSalon: $codigoSalon, codigoCurso: $codigoCurso, horaInicio: $horaInicio, horaFin: $horaFin, esActual: $esActual, esProximo: $esProximo}';
  }
}
