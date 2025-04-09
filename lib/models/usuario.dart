// lib/models/usuario.dart
class Usuario {
  final int id;
  final String nombre;
  final String correoElectronico;
  final String? telefono;
  final String? ubicacion;
  final String? historialParticipacion;
  final String? contrasena; // ← nuevo

  Usuario({
    required this.id,
    required this.nombre,
    required this.correoElectronico,
    this.telefono,
    this.ubicacion,
    this.historialParticipacion,
    this.contrasena,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        correoElectronico: json['correo_electronico'] as String,
        telefono: json['telefono'] as String?,
        ubicacion: json['ubicacion'] as String?,
        historialParticipacion: json['historial_participacion'] as String?,
        contrasena: json['contraseña'] as String?, // ← mapeo
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'correo_electronico': correoElectronico,
        'telefono': telefono,
        'ubicacion': ubicacion,
        'historial_participacion': historialParticipacion,
        'contraseña': contrasena, // ← para serializar
      };
}
