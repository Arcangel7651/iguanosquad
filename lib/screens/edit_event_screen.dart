import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iguanosquad/services/actividad_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditEventScreen extends StatefulWidget {
  final String nombre;
  final DateTime fechaDesde;
  const EditEventScreen(
      {Key? key, required this.nombre, required this.fechaDesde})
      : super(key: key);

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late int idEvent;
  final tituloController = TextEditingController();
  final fechaController = TextEditingController();
  final ubicacionController = TextEditingController();
  final descripcionController = TextEditingController();
  final cuposController = TextEditingController();
  final materialesController = TextEditingController();
  final tipoActividadController = TextEditingController();
  String? categoriaSeleccionada;
  final userIdd = Supabase.instance.client.auth.currentUser?.id;
  DateTime? _selectedDate;
  bool cargando = true;
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  late String? _existingImageUrl;
  late String? _existingImageUrlCopy;

  @override
  void initState() {
    super.initState();
    cargarDatos();
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

  Future<void> cargarDatos() async {
    final actividades = await ActivityService().obtenerActividades(
      nombre: widget.nombre,
      fechaDesde: widget.fechaDesde,
      userId: userIdd,
    );
    if (actividades.isNotEmpty) {
      final a = actividades.first;
      tituloController.text = a.nombre;
      _selectedDate = a.fechaHora;
      ubicacionController.text = a.ubicacion ?? '';
      descripcionController.text = a.descripcion ?? '';
      categoriaSeleccionada = a.tipoCategoria;
      cuposController.text = a.disponibilidadCupos.toString();
      materialesController.text = a.materialesRequeridos ?? '';
      tipoActividadController.text = a.tipoActividad ?? '';
      idEvent = a.id;
      _existingImageUrl = a.urlImage!;
      _existingImageUrlCopy = a.urlImage!;
    }
    setState(() => cargando = false);
  }

  Future<void> guardarDatos() async {
    print("Actualizando datos....");
    // Validaciones básicas
    if (tituloController.text.isEmpty ||
        _selectedDate == null ||
        ubicacionController.text.isEmpty ||
        categoriaSeleccionada == null ||
        cuposController.text.isEmpty ||
        tipoActividadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, rellena todos los campos obligatorios')),
      );
      return;
    }

    // Parsea cupos a entero
    final int? cupos = int.tryParse(cuposController.text);
    if (cupos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cupos debe ser un número válido')),
      );
      return;
    }

    // Llamada al servicio
    final bool exito = await ActivityService().actualizarActividad(
      id: idEvent,
      nombre: tituloController.text,
      fechaHora: _selectedDate!,
      ubicacion: ubicacionController.text,
      descripcion: descripcionController.text,
      tipoCategoria: categoriaSeleccionada!,
      cupos: cupos,
      materialesRequeridos: materialesController.text,
      tipoActividad: tipoActividadController.text,
    );

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento actualizado exitosamente')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el evento')),
      );
    }
  }

  InputDecoration _inputDecoration({Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Editar Evento'),
                      Text('Modifica los detalles de tu evento'),
                    ],
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  floating: true,
                  snap: true,
                  pinned: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const Text('Título del Evento',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextField(
                          controller: tituloController,
                          decoration: _inputDecoration()),
                      const SizedBox(height: 16),
                      const Text('Fecha y Hora',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                  _selectedDate ?? DateTime.now()),
                            );
                            if (time != null) {
                              setState(() {
                                _selectedDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    time.hour,
                                    time.minute);
                              });
                            }
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
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
                      const Text('Ubicación',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: ubicacionController,
                        decoration: _inputDecoration(
                            prefixIcon: const Icon(Icons.location_on_outlined)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Categoría',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: categoriaSeleccionada,
                            isExpanded: true,
                            items: const [
                              'limpieza',
                              'reciclaje',
                              'educacion',
                              'plantacion'
                            ]
                                .map((v) =>
                                    DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => categoriaSeleccionada = v),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Cupos Disponibles',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: cuposController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                            suffixIcon: const Icon(Icons.confirmation_number)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Tipo de Actividad',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: tipoActividadController.text.isEmpty
                                ? null
                                : tipoActividadController.text,
                            isExpanded: true,
                            hint: const Text('Selecciona tipo'),
                            items: const ['Presencial', 'Virtual']
                                .map((v) =>
                                    DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                            onChanged: (v) => setState(
                                () => tipoActividadController.text = v!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Materiales Requeridos',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: materialesController,
                        maxLines: 4,
                        decoration: _inputDecoration(),
                      ),

                      const SizedBox(height: 16),
                      const Text('Descripción',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descripcionController,
                        maxLines: 4,
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 16),
                      // Selector de imagen
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: InkWell(
                          onTap: () async {
                            await _pickImage();
                            setState(() {});
                          },
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: _selectedImage != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedImage = null;
                                            });
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : (_existingImageUrl != null &&
                                        _existingImageUrl!.isNotEmpty)
                                    ? Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              _existingImageUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _existingImageUrl = null;
                                                });
                                              },
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(4),
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.add_photo_alternate,
                                                size: 40, color: Colors.grey),
                                            SizedBox(height: 8),
                                            Text('Agregar imagen',
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Botones
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: guardarDatos,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Guardar Cambios',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black54,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cancelar',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}
