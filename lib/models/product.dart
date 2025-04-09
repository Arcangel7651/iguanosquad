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
    List<String>? imagesList;
    if (json['imgs'] != null) {
      imagesList = List<String>.from(json['imgs'] as List);
    }

    return Product(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      estado: json['estado'],
      precio: json['precio'] != null ? (json['precio'] as num).toDouble() : null,
      ubicacion: json['ubicacion'],
      imgs: imagesList,
      tipoCategoria: json['tipo_categoria'],
    );
  }
}