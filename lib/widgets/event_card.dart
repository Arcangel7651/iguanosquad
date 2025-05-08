// lib/widgets/event_card.dart

import 'package:flutter/material.dart';
import '../screens/edit_event_screen.dart';

class EventCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final String location;
  final String description;
  final int participants;
  final bool isActive;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.participants,
    this.isActive = true,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Formatear fecha a "22 de abril, 2023"
    final formattedDate =
        '${date.day} de ${_spanishMonth(date.month)}, ${date.year}';

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
            // Título + botones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        print("Precionaste el boton de editar");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditEventScreen(
                              nombre: title,
                              fechaDesde: date,
                            ),
                          ),
                        );
                      },
                    ),
                    /*IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                    ),*/
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Fecha
            Row(children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                formattedDate,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ]),

            const SizedBox(height: 4),

            // Ubicación
            Row(children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                location,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ]),

            const SizedBox(height: 16),

            // Descripción
            Text(description),

            const SizedBox(height: 16),

            // Participantes + estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '$participants participantes',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ]),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: isActive ? Colors.green[800] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _spanishMonth(int month) {
    const meses = [
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return meses[month];
  }
}
