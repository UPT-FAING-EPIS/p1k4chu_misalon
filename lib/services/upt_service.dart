import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../models/course.dart';

class UptService {
  static const String baseUrl = 'https://net.upt.edu.pe';
  String? _sessionId;
  String? _cookies;
  final http.Client _client = http.Client();

  // Método para inicializar sesión y obtener la URL del CAPTCHA
  Future<String> initializeSession() async {
    try {
      // Solo inicializar si no hay cookies activas
      if (_cookies == null) {
        // Primero acceder a la página principal para establecer la sesión
        final loginPageResponse = await _client.get(
          Uri.parse('$baseUrl/'),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3',
            'Connection': 'keep-alive',
          },
        );

        // Extraer y almacenar cookies
        final setCookieHeader = loginPageResponse.headers['set-cookie'];
        if (setCookieHeader != null) {
          _cookies = setCookieHeader;
          print('Nueva sesión inicializada. Cookies: $_cookies');
        }
      } else {
        print('Usando sesión existente. Cookies: $_cookies');
      }

      // Devolver URL del CAPTCHA con timestamp para evitar caché
      return '$baseUrl/imagen.php?${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('Error inicializando sesión: $e');
      return '$baseUrl/imagen.php?${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Método para forzar nueva sesión (usado cuando se refresca CAPTCHA)
  Future<String> refreshSession() async {
    _cookies = null; // Limpiar cookies existentes
    _currentKeyboardMapping.clear(); // Limpiar mapeo del teclado
    return await initializeSession();
  }

  // Método para obtener la URL de la imagen CAPTCHA (simplificado)
  String getCaptchaImageUrl() {
    return '$baseUrl/imagen.php?${DateTime.now().millisecondsSinceEpoch}';
  }

  // Método para obtener las cookies actuales
  String? getCurrentCookies() {
    return _cookies;
  }

  // Variable para almacenar el mapeo del teclado virtual actual
  Map<String, String> _currentKeyboardMapping = {};

  // Método para cargar el HTML de login y extraer el mapeo del teclado
  Future<void> _loadKeyboardMapping() async {
    try {
      final loginPageResponse = await _client.get(
        Uri.parse('$baseUrl/'),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3',
          'Connection': 'keep-alive',
          if (_cookies != null) 'Cookie': _cookies!,
        },
      );

      if (loginPageResponse.statusCode == 200) {
        // Extraer el mapeo del teclado virtual
        _currentKeyboardMapping.clear();
        final keyboardRegex = RegExp(
          "onclick=\"js:setChar\\('([0-9])'\\);\">([0-9])</button>",
          caseSensitive: false,
        );
        final keyboardMatches = keyboardRegex.allMatches(
          loginPageResponse.body,
        );

        for (final match in keyboardMatches) {
          final virtualValue = match.group(1);
          final displayValue = match.group(2);
          if (virtualValue != null && displayValue != null) {
            _currentKeyboardMapping[displayValue] = virtualValue;
            print('Mapeo teclado ACTUAL: $displayValue -> $virtualValue');
          }
        }
      }
    } catch (e) {
      print('Error obteniendo mapeo del teclado: $e');
    }
  }

  // Método para cargar imagen CAPTCHA usando las mismas cookies
  Future<List<int>?> loadCaptchaImage() async {
    try {
      // Primero obtener el mapeo del teclado virtual de la sesión actual
      await _loadKeyboardMapping();

      final response = await _client.get(
        Uri.parse('$baseUrl/imagen.php'),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
          'Referer': '$baseUrl/',
          if (_cookies != null) 'Cookie': _cookies!,
        },
      );

      if (response.statusCode == 200) {
        print('CAPTCHA cargado correctamente con cookies de sesión');
        return response.bodyBytes;
      }
    } catch (e) {
      print('Error cargando CAPTCHA: $e');
    }
    return null;
  }

  // Método para hacer login
  Future<bool> login({
    required String codigo,
    required String password,
    required String imagen,
  }) async {
    try {
      // Si no hay cookies o mapeo del teclado, inicializar sesión primero
      if (_cookies == null || _currentKeyboardMapping.isEmpty) {
        print('No hay cookies o mapeo del teclado, inicializando sesión...');
        await initializeSession();
      }

      print('Cookies siendo usadas: $_cookies');
      print(
        'Mapeo de teclado actual disponible: ${_currentKeyboardMapping.isNotEmpty}',
      );

      // Usar el mapeo del teclado virtual obtenido cuando se cargó el CAPTCHA
      if (_currentKeyboardMapping.isEmpty) {
        print('ERROR: No hay mapeo del teclado virtual disponible');
        return false;
      }

      // Convertir contraseña usando el mapeo del teclado virtual ACTUAL
      String convertedPassword = '';
      for (int i = 0; i < password.length; i++) {
        final digit = password[i];
        final mappedValue = _currentKeyboardMapping[digit];
        if (mappedValue != null) {
          convertedPassword += mappedValue;
        } else {
          print(
            'ADVERTENCIA: Dígito $digit no encontrado en teclado virtual actual',
          );
          convertedPassword +=
              digit; // usar el valor original si no se encuentra mapeo
        }
      }

      print('Contraseña original: $password');
      print('Contraseña convertida con mapeo ACTUAL: $convertedPassword');

      // Preparamos los datos del formulario según el HTML de la intranet
      final formData = <String, String>{
        't1': codigo, // Campo código
        't2':
            convertedPassword, // Campo contraseña (convertida con teclado virtual)
        'kamousagi': imagen, // Campo imagen (CAPTCHA)
        'Submit': 'Enviar', // Botón submit
        'redirectto': '', // Campo oculto
      };

      print('Datos enviados: $formData');

      // Hacemos POST a login.php (el endpoint correcto según el HTML)
      final loginResponse = await _client.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Referer': '$baseUrl/',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
          if (_cookies != null) 'Cookie': _cookies!,
        },
        body: formData,
      );

      print('Login response status: ${loginResponse.statusCode}');
      print('Login response headers: ${loginResponse.headers}');
      print(
        'Login response body preview: ${loginResponse.body.substring(0, min(500, loginResponse.body.length))}',
      );

      // Verificar si es una redirección (código 302) o si hay indicadores de éxito
      if (loginResponse.statusCode == 302 || loginResponse.statusCode == 200) {
        final responseBody = loginResponse.body;
        final location = loginResponse.headers['location'];

        // Caso 1: Redirección a inicio.php (login exitoso)
        if (location != null && location.contains('inicio.php')) {
          final sessionRegex = RegExp(r'sesion=([A-Za-z0-9]+)');
          final match = sessionRegex.firstMatch(location);

          if (match != null) {
            _sessionId = match.group(1);

            // Actualizar cookies para incluir la cookie de sesión
            final setCookieHeader = loginResponse.headers['set-cookie'];
            if (setCookieHeader != null) {
              // Combinar cookies existentes con la nueva cookie de sesión
              final existingCookies = _cookies ?? '';
              final sessionCookie =
                  '$_sessionId=${setCookieHeader.split('=')[1].split(';')[0]}';
              _cookies = '$existingCookies; $sessionCookie';
              print('Cookies actualizadas con sesión: $_cookies');
            }

            print('Login exitoso! Sesión: $_sessionId');
            return true;
          }
        }

        // Caso 2: Formulario de continuación automática (login exitoso)
        if (responseBody.contains('login.php?sesion=') &&
            responseBody.contains('function btime()') &&
            responseBody.contains('document.frmlogin.submit()')) {
          final sessionRegex = RegExp(r'login\.php\?sesion=([A-Za-z0-9]+)');
          final match = sessionRegex.firstMatch(responseBody);

          if (match != null) {
            _sessionId = match.group(1);

            // Actualizar cookies para incluir la cookie de sesión
            final setCookieHeader = loginResponse.headers['set-cookie'];
            if (setCookieHeader != null) {
              // Combinar cookies existentes con la nueva cookie de sesión
              final existingCookies = _cookies ?? '';
              final sessionCookie =
                  '$_sessionId=${setCookieHeader.split('=')[1].split(';')[0]}';
              _cookies = '$existingCookies; $sessionCookie';
              print('Cookies actualizadas con sesión: $_cookies');
            }

            print(
              '¡LOGIN EXITOSO! Formulario de continuación detectado. Sesión: $_sessionId',
            );
            return true;
          }
        }

        // Caso 3: Contenido HTML que indica redirección (JavaScript o meta refresh)
        if (responseBody.contains('inicio.php') ||
            responseBody.contains('window.location') ||
            responseBody.contains('location.href') ||
            responseBody.contains('meta') && responseBody.contains('refresh')) {
          final sessionRegex = RegExp(r'sesion=([A-Za-z0-9]+)');
          final match = sessionRegex.firstMatch(responseBody);

          if (match != null) {
            _sessionId = match.group(1);
            print('Login exitoso (redirección JS)! Sesión: $_sessionId');
            return true;
          }
        }

        // Caso 4: Si no hay error de credenciales, pero tampoco redirección
        if (!responseBody.contains('error') &&
            !responseBody.contains('incorrecto') &&
            !responseBody.contains('incorrecta') &&
            responseBody.contains('inicio.php')) {
          // Intentar extraer sesión del HTML
          final sessionRegex = RegExp(r'sesion=([A-Za-z0-9]+)');
          final match = sessionRegex.firstMatch(responseBody);

          if (match != null) {
            _sessionId = match.group(1);
            print('Login exitoso (caso 4)! Sesión: $_sessionId');
            return true;
          }
        }

        // Caso 5: Buscar redirección JavaScript en todo el HTML
        final jsRedirectRegex = RegExp(
          r'window\.location.*?inicio\.php.*?sesion=([A-Za-z0-9]+)',
        );
        final jsMatch = jsRedirectRegex.firstMatch(responseBody);

        if (jsMatch != null) {
          _sessionId = jsMatch.group(1);
          print('Login exitoso (JS redirect)! Sesión: $_sessionId');
          return true;
        }

        // Caso 6: Buscar si simplemente no hay error en la respuesta
        print('Analizando respuesta larga...');
        print('Longitud: ${responseBody.length}');
        print('¿Contiene Usuario? ${responseBody.contains('Usuario:')}');
        print('¿Contiene alumno.php? ${responseBody.contains('alumno.php')}');
        print('¿Contiene logout.php? ${responseBody.contains('logout.php')}');
        print('¿Contiene sesion=? ${responseBody.contains('sesion=')}');

        // Buscar mensajes de error específicos
        print(
          '¿Contiene "invalida"? ${responseBody.toLowerCase().contains('invalida')}',
        );
        print(
          '¿Contiene "incorrecta"? ${responseBody.toLowerCase().contains('incorrecta')}',
        );
        print(
          '¿Contiene "alert"? ${responseBody.toLowerCase().contains('alert')}',
        );
        print(
          '¿Contiene "script"? ${responseBody.toLowerCase().contains('script')}',
        );

        // Buscar scripts de redirección o validación
        if (responseBody.contains('<script')) {
          final scriptRegex = RegExp(
            r'<script[^>]*>(.*?)</script>',
            multiLine: true,
            dotAll: true,
          );
          final scriptMatches = scriptRegex.allMatches(responseBody);
          print('Scripts encontrados: ${scriptMatches.length}');
          for (final match in scriptMatches.take(3)) {
            final script = match
                .group(1)
                ?.substring(0, min(200, match.group(1)?.length ?? 0));
            print('Script: $script');
          }
        }

        if (!responseBody.toLowerCase().contains('error') &&
            !responseBody.toLowerCase().contains('incorrecto') &&
            !responseBody.toLowerCase().contains('incorrect') &&
            !responseBody.toLowerCase().contains('invalid') &&
            responseBody.contains('Universidad Privada de Tacna') &&
            responseBody.length > 5000) {
          // El dashboard es más largo que la página de login
          print(
            'Posible login exitoso (sin errores detectados). Verificando contenido...',
          );

          // Verificar si ya estamos en el dashboard
          if (responseBody.contains('Usuario:') &&
              responseBody.contains('Finalizar')) {
            // Buscar sesión en esta misma respuesta
            final sessionRegex = RegExp(r'sesion=([A-Za-z0-9]+)');
            final match = sessionRegex.firstMatch(responseBody);

            if (match != null) {
              _sessionId = match.group(1);

              // Actualizar cookies para incluir la cookie de sesión
              final setCookieHeader = loginResponse.headers['set-cookie'];
              if (setCookieHeader != null) {
                // Combinar cookies existentes con la nueva cookie de sesión
                final existingCookies = _cookies ?? '';
                final sessionCookie =
                    '$_sessionId=${setCookieHeader.split('=')[1].split(';')[0]}';
                _cookies = '$existingCookies; $sessionCookie';
                print('Cookies actualizadas con sesión: $_cookies');
              }

              print(
                '¡LOGIN EXITOSO! Ya estamos en dashboard. Sesión: $_sessionId',
              );
              return true;
            }
          }

          // Intentar acceso directo a inicio.php para obtener sesión
          try {
            final testResponse = await _client.get(
              Uri.parse('$baseUrl/inicio.php'),
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              },
            );

            if (testResponse.statusCode == 200 &&
                testResponse.body.contains('Usuario:') &&
                testResponse.body.contains('alumno.php')) {
              // Buscar sesión en la respuesta
              final sessionRegex = RegExp(r'sesion=([A-Za-z0-9]+)');
              final match = sessionRegex.firstMatch(testResponse.body);

              if (match != null) {
                _sessionId = match.group(1);
                print('Login exitoso (acceso directo)! Sesión: $_sessionId');
                return true;
              }
            }
          } catch (e) {
            print('Error en verificación directa: $e');
          }
        }

        // Si llegamos aquí, el login falló
        print('Login fallido. Respuesta no contiene indicadores de éxito.');
        print('Longitud de respuesta: ${responseBody.length}');
        print(
          'Contenido de respuesta: ${responseBody.substring(0, min(300, responseBody.length))}',
        );
        return false;
      }

      print(
        'Login fallido. Código de respuesta inesperado: ${loginResponse.statusCode}',
      );
      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  // Método para obtener el horario
  Future<List<Course>> getSchedule() async {
    if (_sessionId == null) {
      throw Exception('No hay sesión activa. Debe hacer login primero.');
    }

    try {
      print('Obteniendo horario con sesión: $_sessionId');

      // Navegamos a la página de alumno primero
      final alumnoUrl = '$baseUrl/alumno.php?sesion=$_sessionId';
      print('Navegando a página de alumno: $alumnoUrl');

      final alumnoResponse = await _client.get(
        Uri.parse(alumnoUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3',
          'Connection': 'keep-alive',
          if (_cookies != null) 'Cookie': _cookies!,
        },
      );

      if (alumnoResponse.statusCode != 200) {
        print(
          'Error al acceder a página de alumno: ${alumnoResponse.statusCode}',
        );
        throw Exception('Error al acceder a la página de alumno');
      }

      print('Página de alumno accedida exitosamente');

      // Navegamos a la página de horario con mihorario=1
      final horarioUrl = '$baseUrl/alumno.php?mihorario=1&sesion=$_sessionId';
      print('Navegando a página de horario: $horarioUrl');

      final horarioResponse = await _client.get(
        Uri.parse(horarioUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3',
          'Connection': 'keep-alive',
          'Referer': alumnoUrl,
          if (_cookies != null) 'Cookie': _cookies!,
        },
      );

      if (horarioResponse.statusCode != 200) {
        print(
          'Error al acceder a página de horario: ${horarioResponse.statusCode}',
        );
        print(
          'Respuesta: ${horarioResponse.body.substring(0, min(500, horarioResponse.body.length))}',
        );
        throw Exception('Error al acceder a la página de horario');
      }

      print('Página de horario accedida exitosamente. Parseando datos...');
      print('Longitud de respuesta: ${horarioResponse.body.length}');

      // Si la respuesta es muy pequeña, probablemente hay un problema de sesión
      if (horarioResponse.body.length < 1000) {
        print('RESPUESTA PEQUEÑA - Posible problema de sesión:');
        print(horarioResponse.body);
      }

      // Parseamos el HTML para extraer los datos de la tabla
      return _parseScheduleFromHtml(horarioResponse.body);
    } catch (e) {
      print('Error obteniendo horario: $e');
      throw Exception('Error al obtener el horario: $e');
    }
  }

  // Método para parsear el HTML y extraer los cursos
  List<Course> _parseScheduleFromHtml(String htmlContent) {
    final List<Course> courses = [];

    try {
      print('Iniciando parseo de HTML...');

      // Parse del documento HTML con la librería html
      final document = html_parser.parse(htmlContent);

      // Buscamos todas las tablas en el documento
      final tables = document.querySelectorAll('table');
      print('Número de tablas encontradas: ${tables.length}');

      // Buscar la tabla que contiene los horarios
      for (int tableIndex = 0; tableIndex < tables.length; tableIndex++) {
        final table = tables[tableIndex];
        final rows = table.querySelectorAll('tr');

        print('Tabla $tableIndex tiene ${rows.length} filas');

        // Verificar si es la tabla de horarios buscando encabezados característicos
        if (rows.isNotEmpty) {
          final firstRowText = rows.first.text.toLowerCase();
          print(
            'Primera fila de tabla $tableIndex: ${firstRowText.substring(0, min(100, firstRowText.length))}',
          );

          // Buscar tabla que contenga columnas de días de la semana
          if (firstRowText.contains('codigo') ||
              firstRowText.contains('curso') ||
              firstRowText.contains('lunes') ||
              firstRowText.contains('martes')) {
            print('¡Tabla de horarios encontrada en índice $tableIndex!');

            // Encontrar la fila de encabezados
            int headerRowIndex = -1;
            for (int i = 0; i < rows.length; i++) {
              final rowText = rows[i].text.toLowerCase();
              if (rowText.contains('codigo') && rowText.contains('curso')) {
                headerRowIndex = i;
                print('Fila de encabezados encontrada en índice: $i');
                break;
              }
            }

            if (headerRowIndex == -1) {
              print('No se encontró fila de encabezados, usando primera fila');
              headerRowIndex = 0;
            }

            // Procesar las filas de datos (después de los encabezados)
            for (int i = headerRowIndex + 1; i < rows.length; i++) {
              final row = rows[i];
              final cells = row.querySelectorAll('td, th');

              print('Procesando fila $i con ${cells.length} celdas');

              if (cells.length >= 7) {
                // Mínimo: Código, Curso, Sección, y días de la semana
                final codigo = cells[0].text.trim();
                final nombre = cells[1].text.trim();
                final seccion = cells.length > 2 ? cells[2].text.trim() : '';

                print('Curso encontrado: $codigo - $nombre - $seccion');

                if (codigo.isNotEmpty && nombre.isNotEmpty) {
                  // Mapear horarios por día de la semana
                  Map<String, String> horarios = {};

                  // Mapeo de las columnas según la estructura esperada
                  final diasSemana = [
                    'lunes',
                    'martes',
                    'miércoles',
                    'jueves',
                    'viernes',
                    'sábado',
                    'domingo',
                  ];

                  // Empezar desde la columna 3 (después de código, curso, sección)
                  for (
                    int dayIndex = 0;
                    dayIndex < diasSemana.length &&
                        (3 + dayIndex) < cells.length;
                    dayIndex++
                  ) {
                    final horarioText = cells[3 + dayIndex].text.trim();
                    final horarioFormateado = _formatearHorario(horarioText);
                    horarios[diasSemana[dayIndex]] = horarioFormateado;

                    if (horarioFormateado.isNotEmpty) {
                      print('  ${diasSemana[dayIndex]}: $horarioFormateado');
                    }
                  }

                  courses.add(
                    Course(
                      codigo: codigo,
                      nombre: nombre,
                      seccion: seccion,
                      horarios: horarios,
                    ),
                  );
                }
              } else {
                print(
                  'Fila $i tiene muy pocas celdas (${cells.length}), saltando...',
                );
              }
            }

            // Si encontramos cursos en esta tabla, no necesitamos seguir buscando
            if (courses.isNotEmpty) {
              print(
                '${courses.length} cursos encontrados en tabla de horarios',
              );
              break;
            }
          }
        }
      }

      // Si no encontramos nada, intentar buscar información de cursos en cualquier parte del HTML
      if (courses.isEmpty) {
        print(
          'No se encontró tabla de horarios, buscando información de cursos en el HTML...',
        );

        // Buscar patrones de códigos de curso (ej: SI-881, SI-882, etc.)
        final courseCodeRegex = RegExp(r'[A-Z]{2}-\d{3}');
        final courseMatches = courseCodeRegex.allMatches(htmlContent);

        print('Códigos de curso encontrados: ${courseMatches.length}');

        for (final match in courseMatches) {
          final code = match.group(0);
          print('Código encontrado: $code');
        }
      }
    } catch (e) {
      print('Error parseando HTML: $e');
      print('Stack trace: ${StackTrace.current}');
    }

    // Si no se encontraron cursos, lanzar excepción con información específica
    if (courses.isEmpty) {
      print('ERROR: No se pudieron extraer cursos del HTML');
      throw Exception(
        'No se encontraron horarios de cursos en la respuesta del servidor. La página podría estar vacía o tener un formato diferente al esperado.',
      );
    }

    print('Total de cursos extraídos: ${courses.length}');
    return courses;
  }

  // Función para formatear horarios de "15:0016:40" a "15:00 - 16:40"
  String _formatearHorario(String horarioText) {
    if (horarioText.isEmpty) return '';

    // Buscar patrones de tiempo como "15:0016:40" o "15:00\n16:40"
    final RegExp timePattern = RegExp(r'(\d{1,2}):(\d{2})');
    final matches = timePattern.allMatches(horarioText);

    if (matches.length >= 2) {
      // Si hay al menos 2 horas encontradas, formatear como rango
      final List<String> horas = matches
          .map((match) => match.group(0)!)
          .toList();
      return '${horas[0]} - ${horas[1]}';
    } else if (matches.length == 1) {
      // Si solo hay una hora, devolverla tal como está
      return matches.first.group(0)!;
    }

    // Si no se encuentra patrón de tiempo, devolver texto original limpio
    return horarioText.replaceAll('\n', ' - ').trim();
  }

  void dispose() {
    _client.close();
  }
}
