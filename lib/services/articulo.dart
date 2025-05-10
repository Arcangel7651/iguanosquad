import 'package:iguanosquad/models/Articulo.dart';
import 'package:iguanosquad/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'articulo.dart'; // Asegúrate de importar el modelo Articulo

class ArticuloService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> crearArticulo(Articulo articulo) async {
    final response = await _supabase
        .from('articulo') // Nombre de la tabla
        .insert(articulo.toJson())
        .execute();

    return 'Artículo creado exitosamente';
  }

  Future<List<Product>> getProductsByUser(String userId) async {
    final response = await _supabase
        .from('articulo')
        .select()
        .eq('id_usuario', userId)
        .order('id', ascending: false) // Los más recientes primero
        .execute();

    final data = response.data as List<dynamic>;
    // Mapear cada fila JSON a un Product
    return data
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
