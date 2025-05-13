import 'package:flutter/material.dart';
import '../models/product.dart';

class ArticleCard extends StatelessWidget {
  final Product article;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ArticleCard({
    Key? key,
    required this.article,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtén la primera URL si la lista no está vacía
    final String? firstImageUrl =
        (article.imgs != null && article.imgs!.isNotEmpty)
            ? article.imgs!.first
            : null;

    return Card(
      color: Color.fromARGB(255, 255, 255, 255),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row de título y botones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  article.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Precio y categoría
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  article.precio?.toStringAsFixed(2) ?? '-',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  article.tipoCategoria ?? '-',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Primera imagen o placeholder
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              clipBehavior: Clip.hardEdge,
              child: firstImageUrl != null
                  ? Image.network(
                      firstImageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stack) => const Center(
                        child: Icon(Icons.broken_image,
                            size: 40, color: Colors.grey),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
            ),

            const SizedBox(height: 16),

            // Descripción
            Text(article.descripcion ?? ''),

            const SizedBox(height: 16),

            // Estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                article.estado ?? '',
                style: TextStyle(color: Colors.blue[800], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
