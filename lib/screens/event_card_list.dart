// lib/widgets/event_card_list.dart

import 'package:flutter/material.dart';
import 'package:iguanosquad/services/actividad_service.dart';
import 'package:iguanosquad/widgets/event_card.dart'; // Asegúrate de importar tu widget personalizado
import '../widgets/event_card.dart';

class EventCardList extends StatefulWidget {
  final String userId; // <-- Este debe ser el ID del usuario

  const EventCardList({super.key, required this.userId});

  @override
  State<EventCardList> createState() => _EventCardListState();
}

class _EventCardListState extends State<EventCardList> {
  late Future<List<Map<String, dynamic>>> _futureEventos;

  @override
  void initState() {
    super.initState();
    _futureEventos =
        ActivityService().obtenerActividadesPorUsuario(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureEventos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final eventos = snapshot.data ?? [];

        if (eventos.isEmpty) {
          return const Center(child: Text('No hay actividades aún.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: eventos.length,
          itemBuilder: (context, index) {
            final evento = eventos[index];
            return EventCard(
              title: evento['nombre'],
              date: DateTime.parse(evento['fecha_hora']),
              location: evento['ubicacion'] ?? 'Ubicación no especificada',
              description: evento['descripcion'] ?? '',
              participants: 0, // <-- Ajusta si tienes este dato
              isActive: true, // <-- Ajusta si tienes este dato
              onEdit: () {},
              onDelete: () {},
            );
          },
        );
      },
    );
  }
}
