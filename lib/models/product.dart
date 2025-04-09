// lib/models/product.dart
class Product {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? estado;
  final double? precio;
  final String? ubicacion;
  final List<String>? imgs;
  final String? tipoCategoria;

  Product({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.estado,
    this.precio,
    this.ubicacion,
    this.imgs,
    this.tipoCategoria,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String>? imgsList;
    
    // Manejo del campo 'imgs' que es jsonb en la base de datos
    if (json['imgs'] != null) {
      if (json['imgs'] is List) {
        imgsList = List<String>.from(json['imgs']);
      } else if (json['imgs'] is String) {
        // Si por alguna razón viene como String (podría pasar si es un JSON string)
        try {
          var decoded = jsonDecode(json['imgs']);
          if (decoded is List) {
            imgsList = List<String>.from(decoded);
          }
        } catch (_) {
          imgsList = [json['imgs']];
        }
      }
    }

    return Product(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      estado: json['estado'],
      precio: json['precio'] != null ? double.parse(json['precio'].toString()) : null,
      ubicacion: json['ubicacion'],
      imgs: imgsList,
      tipoCategoria: json['tipo_categoria'],
    );
  }
}