// lib/constants/product_categories.dart
class ProductCategories {
  static const String todos = 'todos';
  static const String electronico = 'Electrónico';
  static const String ropa = 'Ropa';
  static const String mueble = 'Mueble';
  static const String cocina = 'Cocina';

  static List<String> get values => [
    electronico,
    ropa,
    mueble,
    cocina,
  ];

  static List<String> estados = [
    'Nuevo',
    'Como Nuevo',
    'Usado',
  ];
}