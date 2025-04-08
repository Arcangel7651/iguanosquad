import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Inicia sesión con Supabase Auth y luego obtiene la fila de `usuario`
  Future<Usuario> login({
    required String email,
    required String password,
  }) async {
    // 1. Autenticar
    final authRes = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final session = authRes.session;
    if (session == null) {
      throw Exception('Credenciales inválidas');
    }

    // 2. Leer datos de la tabla `usuario`
    final resp = await _supabase
        .from('usuario')
        .select()
        .eq('correo_electronico', email)
        .single()
        .execute();

    final data = resp.data as Map<String, dynamic>;
    return Usuario.fromJson(data);
  }

  /// Cierra la sesión
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  /// Registra un nuevo usuario en Auth y en la tabla `usuario`
  Future<Usuario> register({
    required String nombre,
    required String email,
    required String password,
    required String ubicacion,
  }) async {
    // 1. Crear credenciales en Auth de Supabase (metadata con 'data')
    final res = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'nombre': nombre,
        'ubicacion': ubicacion,
      },
    );

    if (res.user == null) {
      throw Exception('Error al crear la cuenta: revisa tus credenciales');
    }

    // 2. Insertar fila en la tabla `usuario` (id serial se genera solo)
    final insertRes = await _supabase
        .from('usuario')
        .insert({
          'nombre': nombre,
          'correo_electronico': email,
          'ubicacion': ubicacion,
        })
        .select() // para que devuelva el registro insertado
        .single()
        .execute();

    final data = insertRes.data as Map<String, dynamic>;
    return Usuario.fromJson(data);
  }
}
