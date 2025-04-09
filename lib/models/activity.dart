// lib/models/activity.dart
class Activity {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? ubicacion;
  final DateTime fechaHora;
  final String? tipoActividad;
  final int? disponibilidadCupos;
  final String? materialesRequeridos;
  final String? urlImage;
  final String? tipoCategoria;

  Activity({
    required this.id,
    required this.nombre,
    required this.fechaHora,
    this.descripcion,
    this.ubicacion,
    this.tipoActividad,
    this.disponibilidadCupos,
    this.materialesRequeridos,
    this.urlImage,
    this.tipoCategoria,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      ubicacion: json['ubicacion'],
      fechaHora: json['fecha_hora'] is String
          ? DateTime.parse(json['fecha_hora'])
          : json['fecha_hora'],
      tipoActividad: json['tipo_actividad'],
      disponibilidadCupos: json['disponibilidad_cupos'],
      materialesRequeridos: json['materiales_requeridos'],
      urlImage: json['url_image'],
      tipoCategoria: json['tipo_categoria'],
    );
  }
  
  // Método para depuración
  @override
  String toString() {
    return 'Activity(id: $id, nombre: $nombre, urlImage: $urlImage)';
  }
}