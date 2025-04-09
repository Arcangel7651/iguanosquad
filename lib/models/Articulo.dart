class Articulo {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? estado;
  final double? precio;
  final String? ubicacion;
  final List<String>? imgs;

  Articulo({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.estado,
    this.precio,
    this.ubicacion,
    this.imgs,
  });

  factory Articulo.fromJson(Map<String, dynamic> json) {
    return Articulo(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      estado: json['estado'],
      precio: json['precio']?.toDouble(),
      ubicacion: json['ubicacion'],
      imgs: json['imgs'] != null ? List<String>.from(json['imgs']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
      'precio': precio,
      'ubicacion': ubicacion,
      'imgs': imgs,
    };
  }
}
