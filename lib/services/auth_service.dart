import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Inicia sesión con Supabase Auth y luego obtiene la fila de `usuario`
  Future<Usuario> login({
    required String email,
    required String password,
  }) async {
    // 1. Autenticar con Supabase Auth
    final authRes = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = authRes.user;
    if (user == null) {
      throw Exception('No se obtuvo sesión de usuario');
    }

    // 2. Traer datos extra del usuario (sin contraseña)
    final resp = await _supabase
        .from('usuario')
        .select(
            'id, nombre, correo_electronico, telefono, ubicacion, historial_participacion')
        .eq('id', user.id)
        .maybeSingle(); // no lanza excepción si no existe

    if (resp.error != null) {
      throw Exception('Error al cargar perfil: ${resp.error!.message}');
    }
    final data = resp.data as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Usuario no encontrado en la tabla “usuario”');
    }

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
    // 1. Crear credenciales en Auth
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

    // 2. Insertar fila en la tabla `usuario`, incluyendo la contraseña
    final insertRes = await _supabase
        .from('usuario')
        .insert({
          'nombre': nombre,
          'correo_electronico': email,
          'ubicacion': ubicacion,
          'contraseña': password, // ← aquí
        })
        .select() // para que devuelva el registro insertado
        .single()
        .execute();

    final data = insertRes.data as Map<String, dynamic>;
    return Usuario.fromJson(data);
  }
}
