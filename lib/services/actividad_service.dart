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
}
