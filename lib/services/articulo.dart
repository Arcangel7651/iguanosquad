import 'package:iguanosquad/models/Articulo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'articulo.dart'; // Asegúrate de importar el modelo Articulo

class ArticuloService {
  final SupabaseClient supabaseClient;

  ArticuloService({required this.supabaseClient});

  Future<String> crearArticulo(Articulo articulo) async {
    final response = await supabaseClient
        .from('articulo') // Nombre de la tabla
        .insert(articulo.toJson())
        .execute();

    return 'Artículo creado exitosamente';
  }
}
