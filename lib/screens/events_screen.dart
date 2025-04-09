// lib/screens/events_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity.dart';
import '../widgets/eco_event_card.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Activity> _activities = [];
  bool _isLoading = true;
  String _selectedCategory = 'todos';
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _materialsController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedActivityType = 'Presencial';
  int? _availableSpots;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _materialsController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    try {
      final response = await _supabase
          .from('actividad_conservacion')
          .select()
          .order('fecha_hora', ascending: true)
          .execute();

      if (response.data != null) {
        setState(() {
          _activities = (response.data as List)
              .map((json) => Activity.fromJson(json))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando actividades: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Activity> _getFilteredActivities() {
    if (_selectedCategory == 'todos') {
      return _activities;
    }
    return _activities
        .where((activity) => activity.tipoCategoria == _selectedCategory)
        .toList();
  }

  Future<void> _createActivity() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      return;
    }

    try {
      await _supabase.from('actividad_conservacion').insert({
        'nombre': _titleController.text,
        'descripcion': _descriptionController.text,
        'ubicacion': _locationController.text,
        'fecha_hora': _selectedDate!.toIso8601String(),
        'tipo_actividad': _selectedActivityType,
        'disponibilidad_cupos': _availableSpots,
        'materiales_requeridos': _materialsController.text,
        'tipo_categoria': _selectedCategory == 'todos' ? 'limpieza' : _selectedCategory,
      }).execute();

      if (mounted) {
        Navigator.pop(context);
        _loadActivities();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la actividad')),
        );
      }
    }
  }

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildCategoryChip('todos', 'Todos'),
                _buildCategoryChip('limpieza', 'Limpieza'),
                _buildCategoryChip('reciclaje', 'Reciclaje'),
                _buildCategoryChip('educacion', 'Educación'),
                _buildCategoryChip('planteacion', 'Plantación'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _getFilteredActivities().isEmpty
                    ? const Center(child: Text('No hay eventos disponibles'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _getFilteredActivities().length,
                        itemBuilder: (context, index) {
                          final activity = _getFilteredActivities()[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: EcoEventCard(
                              title: activity.nombre,
                              date: DateFormat('dd/MM/yyyy HH:mm')
                                  .format(activity.fechaHora),
                              location: activity.ubicacion ?? 'Sin ubicación',
                              description: activity.descripcion ?? '',
                              participants: activity.disponibilidadCupos ?? 0,
                              imageUrl: activity.urlImage,
                              materials: activity.materialesRequeridos,
                              type: activity.tipoActividad ?? 'Presencial',
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: _selectedCategory == value,
        onSelected: (bool selected) {
          setState(() => _selectedCategory = value);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.green[100],
        labelStyle: TextStyle(
          color: _selectedCategory == value
              ? const Color(0xFF4CAF50)
              : Colors.grey[700],
        ),
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nuevo Evento'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Título del Evento',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un título';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _selectedDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha y Hora',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? 'Seleccionar fecha y hora'
                          : DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Ubicación',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedActivityType,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Actividad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Presencial', child: Text('Presencial')),
                    DropdownMenuItem(value: 'Virtual', child: Text('Virtual')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedActivityType = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _materialsController,
                  decoration: InputDecoration(
                    labelText: 'Materiales Requeridos',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cupos Disponibles',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    _availableSpots = int.tryParse(value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _createActivity,
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