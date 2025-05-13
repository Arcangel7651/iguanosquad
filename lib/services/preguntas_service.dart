import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/Preguntas.dart';

class PreguntasService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Pregunta>> obtenerPreguntasUser(String userId) async {
    try {
      final response = await _supabase
          .from('preguntas')
          .select('id_pregunta, pregunta, fecha, id_usuario, usuario(nombre)')
          .eq('id_usuario', userId)
          .order('fecha', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => Pregunta.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener preguntas: $e');
    }
  }

  Future<List<Pregunta>> obtenerTodasLasPreguntas() async {
    try {
      final response = await _supabase.from('preguntas').select('''
        id_pregunta,
        pregunta,
        fecha,
        id_usuario,
        usuario(nombre),
        respuestas(id_respuesta)
      ''').order('fecha', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => Pregunta.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener preguntas: $e');
    }
  }

  Future<void> crearPregunta(String texto) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    await _supabase.from('preguntas').insert({
      'pregunta': texto,
      'fecha': DateTime.now().toIso8601String().split('T')[0],
      'id_usuario': user.id,
    });
  }
}
