// lib/models/product.dart
import 'dart:convert';

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
        // Si viene como una cadena JSON
        try {
          var decoded = jsonDecode(json['imgs']);
          if (decoded is List) {
            imgsList = List<String>.from(decoded);
          }
        } catch (_) {
          imgsList = [json['imgs']];
        }
      } else if (json['imgs'] is Map) {
        // Si viene como un objeto JSON
        imgsList = [];
        (json['imgs'] as Map).forEach((key, value) {
          imgsList!.add(value.toString());
        });
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
  
  // Método de depuración para mostrar el contenido del objeto
  @override
  String toString() {
    return 'Product(id: $id, nombre: $nombre, imgs: $imgs)';
  }
}