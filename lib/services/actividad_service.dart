import 'package:iguanosquad/models/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActividadService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ActividadConservacion> crearActividad({
    required String nombre,
    String? descripcion,
    String? ubicacion,
    required DateTime fechaHora,
    String? tipoActividad,
    int? disponibilidadCupos,
    String? materialesRequeridos,
    String? urlImage,
    String? tipoCategoria,
  }) async {
    final tiposActividadValidos = ['Presencial', 'Virtual'];
    final tiposCategoriaValidos = [
      'limpieza',
      'reciclaje',
      'educacion',
      'planteacion',
    ];

    if (tipoActividad != null &&
        !tiposActividadValidos.contains(tipoActividad)) {
      throw Exception('tipo_actividad inválido');
    }

    if (tipoCategoria != null &&
        !tiposCategoriaValidos.contains(tipoCategoria)) {
      throw Exception('tipo_categoria inválido');
    }

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

    return ActividadConservacion.fromJson(res.data as Map<String, dynamic>);
  }
}
