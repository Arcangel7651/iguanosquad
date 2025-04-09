// lib/screens/events_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import '../constants/categories.dart';
import '../widgets/eco_event_card.dart';
import '../models/activity.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();
  List<Activity> _activities = [];
  bool _isLoading = true;
  String _selectedCategory = Categories.todos;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _materialsController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedActivityType = 'Presencial';
  int? _availableSpots;
  File? _selectedImage;
  bool _isUploadingImage = false;

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
    setState(() => _isLoading = true);
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
        });
      }
    } catch (e) {
      debugPrint('Error cargando actividades: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar las actividades')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      debugPrint('Error seleccionando imagen: $e');
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    setState(() => _isUploadingImage = true);
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(_selectedImage!.path)}';
      final String storageFolder = 'actividades';

      final response = await _supabase.storage
          .from(storageFolder)
          .upload(fileName, _selectedImage!);

      // Obtener la URL pública
      final String imageUrl =
          _supabase.storage.from(storageFolder).getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      return null;
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _createActivity() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      return;
    }

    setState(() => _isUploadingImage = true);
    String? imageUrl;

    try {
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
      }

      await _supabase.from('actividad_conservacion').insert({
        'nombre': _titleController.text,
        'descripcion': _descriptionController.text,
        'ubicacion': _locationController.text,
        'fecha_hora': _selectedDate!.toIso8601String(),
        'tipo_actividad': _selectedActivityType,
        'disponibilidad_cupos': _availableSpots,
        'materiales_requeridos': _materialsController.text,
        'tipo_categoria': _selectedCategory.toLowerCase(),
        'url_image': imageUrl,
      }).execute();

      if (mounted) {
        Navigator.pop(context);
        _loadActivities();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Actividad creada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la actividad')),
        );
      }
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  List<Activity> _getFilteredActivities() {
    if (_selectedCategory == Categories.todos) {
      return _activities;
    }
    return _activities
        .where((activity) =>
            activity.tipoCategoria?.toLowerCase() ==
            _selectedCategory.toLowerCase())
        .toList();
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
                _buildCategoryChip(Categories.todos, 'Todos'),
                ...Categories.values
                    .map((category) => _buildCategoryChip(category, category)),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadActivities,
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
    // Resetear valores
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _materialsController.clear();
    _selectedDate = null;
    _selectedImage = null;
    _availableSpots = null;
    _selectedActivityType = 'Presencial';

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
                // Selector de imagen
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 50, color: Colors.grey),
                              Text('Agregar imagen',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
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
                          : DateFormat('dd/MM/yyyy HH:mm')
                              .format(_selectedDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory == Categories.todos
                      ? Categories.values.first
                      : _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: Categories.values
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
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
                    DropdownMenuItem(
                        value: 'Presencial', child: Text('Presencial')),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el número de cupos';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Por favor ingresa un número válido';
                    }
                    return null;
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una descripción';
                    }
                    return null;
                  },
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
            onPressed: _isUploadingImage ? null : _createActivity,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: _isUploadingImage
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Crear Evento'),
          ),
        ],
      ),
    );
  }
}
