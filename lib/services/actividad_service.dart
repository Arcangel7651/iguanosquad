import 'package:flutter/material.dart';
import 'package:iguanosquad/models/activity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Activity> createActivity({
    required String nombre,
    String? descripcion,
    String? ubicacion,
    required DateTime fechaHora,
    String? tipoActividad, // 'Presencial' | 'Virtual'
    int? disponibilidadCupos,
    String? materialesRequeridos,
    String? urlImage,
    String?
        tipoCategoria, // 'limpieza', 'reciclaje', 'educacion', 'planteacion'
  }) async {
    // Validamos que el tipo de actividad y tipo de categoria sean correctos
    final tiposActividadValidos = ['Presencial', 'Virtual'];
    final tiposCategoriaValidos = [
      'limpieza',
      'reciclaje',
      'educacion',
      'planteacion'
    ];

    if (tipoActividad != null &&
        !tiposActividadValidos.contains(tipoActividad)) {
      throw Exception('Tipo de actividad inválido');
    }

    if (tipoCategoria != null &&
        !tiposCategoriaValidos.contains(tipoCategoria)) {
      throw Exception('Tipo de categoría inválido');
    }

    // Realizamos la inserción en la base de datos
    final res = await _supabase
        .from('actividad_conservacion')
        .insert({
          'nombre': nombre,
          'descripcion': descripcion,
          'ubicacion': ubicacion,
          'fecha_hora': fechaHora.toIso8601String(),
          'tipo_actividad': tipoActividad,
          'disponibilidad_cupos': disponibilidadCupos,
          'materiales_requeridos': materialesRequeridos,
          'url_image': urlImage,
          'tipo_categoria': tipoCategoria,
        })
        .select()
        .single()
        .execute();

    return Activity.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> obtenerActividadesPorUsuario(
      String userId) async {
    final supabase = Supabase.instance.client;

    // Ejecuta la consulta y obtén el PostgrestResponse
    final response = await supabase
        .from('actividad_conservacion')
        .select('nombre, fecha_hora, ubicacion, descripcion')
        .eq('organizador', userId)
        .execute(); // ← ¡IMPORTANTE!

    // Extrae la data, que ya es List<dynamic>
    final data = response.data as List<dynamic>;

    // Si no hay elementos, regresa lista vacía
    if (data.isEmpty) {
      return [];
    }

    // Asegúrate de castear cada elemento a Map<String, dynamic>
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Activity>> obtenerActividades({
    String? nombre,
    DateTime? fechaDesde,
    required String? userId,
  }) async {
    // Eliminamos la declaración genérica <Map<String, dynamic>>
    var query = _supabase
        .from('actividad_conservacion')
        .select('*') // ← Esta es la corrección clave
        .eq('organizador', userId);

    if (nombre != null && nombre.isNotEmpty) {
      query = query.ilike('nombre', '%$nombre%');
    }

    if (fechaDesde != null) {
      query = query.filter(
        'fecha_hora',
        'gte',
        fechaDesde.toIso8601String(),
      );
    }

    final finalQuery = query.order('fecha_hora', ascending: true);

    final response = await finalQuery.execute();

    final data = response.data as List<dynamic>;

    return data
        .map((json) => Activity.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<bool> actualizarActividad({
    required int id,
    required String nombre,
    required DateTime fechaHora,
    required String ubicacion,
    required String descripcion,
    required String tipoCategoria,
    required int cupos,
    required String materialesRequeridos,
    required String tipoActividad,
  }) async {
    final response = await _supabase
        .from('actividad_conservacion')
        .update({
          'nombre': nombre,
          'fecha_hora': fechaHora.toIso8601String(),
          'ubicacion': ubicacion,
          'descripcion': descripcion,
          'tipo_categoria': tipoCategoria,
          'disponibilidad_cupos': cupos,
          'materiales_requeridos': materialesRequeridos,
          'tipo_actividad': tipoActividad,
        })
        .eq('id', id)
        .select()
        .single()
        .execute();

    // Si data es no nulo, damos por exitosa la actualización
    return response.data != null;
  }
}
