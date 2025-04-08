// lib/screens/events_screen.dart
import 'package:flutter/material.dart';
import '../widgets/eco_event_card.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Eventos Ecológicos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Participa y haz la diferencia',
                style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () => _showCreateEventDialog(context),
              icon: const Icon(Icons.add, color: Color(0xFF4CAF50)),
              label: const Text('Crear',
                  style: TextStyle(color: Color(0xFF4CAF50))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Categorías
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildCategoryChip('Todos', true),
                _buildCategoryChip('Limpieza', false),
                _buildCategoryChip('Reciclaje', false),
                _buildCategoryChip('Educación', false),
                _buildCategoryChip('Plantación', false),
              ],
            ),
          ),
          // Lista de eventos
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                EcoEventCard(
                  title: 'Limpieza de Playa Los Verdes',
                  date: '14/04/2023',
                  location: 'Playa Los Verdes, Viña del Mar',
                  description: 'Únete a nuestra jornada de limpieza para mantener nuestras playas libres de plásticos y residuos.',
                  participants: 24,
                ),
                SizedBox(height: 16),
                EcoEventCard(
                  title: 'Taller de Reciclaje Creativo',
                  date: '21/04/2023',
                  location: 'Parque Central, Santiago',
                  description: 'Aprende a transformar residuos en objetos útiles y decorativos. Trae tus materiales reciclables.',
                  participants: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {},
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.green[100],
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[700],
        ),
      ),
    );
  }

  static void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nuevo Evento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Título del Evento',
                  hintText: 'Ej: Limpieza de Playa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  hintText: 'dd/mm/yyyy',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Ubicación',
                  hintText: 'Ej: Parque Central, Santiago',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe los detalles del evento...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Crear Evento'),
          ),
        ],
      ),
    );
  }
}