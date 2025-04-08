class Usuario {
  final int id;
  final String nombre;
  final String correoElectronico;
  final String? telefono;
  final String? ubicacion;
  final String? historialParticipacion;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correoElectronico,
    this.telefono,
    this.ubicacion,
    this.historialParticipacion,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      correoElectronico: json['correo_electronico'] as String,
      telefono: json['telefono'] as String?,
      ubicacion: json['ubicacion'] as String?,
      historialParticipacion: json['historial_participacion'] as String?,
    );
  }
}
