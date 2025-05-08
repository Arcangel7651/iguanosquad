import 'package:flutter/material.dart';
import 'package:iguanosquad/services/actividad_service.dart';
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
  final tituloController = TextEditingController();
  final fechaController = TextEditingController();
  final ubicacionController = TextEditingController();
  final descripcionController = TextEditingController();
  final cuposdisponiblesContrroller = TextEditingController();
  final materialesController = TextEditingController();
  final tipoActividadController = TextEditingController();
  String? categoriaSeleccionada;
  final userIdd = Supabase.instance.client.auth.currentUser?.id;
  DateTime? _selectedDate;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final actividades = await ActivityService().obtenerActividades(
        nombre: widget.nombre, fechaDesde: widget.fechaDesde, userId: userIdd);

    if (actividades.isNotEmpty) {
      final actividad = actividades.first;

      print("Estis son los originales");
      print("Este es el nombre: ${actividad.nombre}");
      print("Este es el nombre: ${actividad.fechaHora}");
      print("Este es el nombre: ${actividad.ubicacion}");
      print("Este es el nombre: ${actividad.descripcion}");
      print("Este es el nombre: ${actividad.tipoCategoria}");
/**/
      print("Este es el nombre: ${actividad.disponibilidadCupos}");
      print("Este es el nombre: ${actividad.materialesRequeridos}");
      print("Este es el nombre: ${actividad.tipoActividad}");

      tituloController.text = actividad.nombre;
      fechaController.text = actividad.fechaHora.toString().split(' ')[0];
      ubicacionController.text = actividad.ubicacion!;
      descripcionController.text = actividad.descripcion!;
      categoriaSeleccionada = actividad.tipoCategoria;
      _selectedDate = actividad.fechaHora;
      cuposdisponiblesContrroller.text =
          actividad.disponibilidadCupos.toString();
      materialesController.text = actividad.materialesRequeridos!;
      tipoActividadController.text = actividad.tipoActividad!;
    }

    setState(() {
      cargando = false;
    });
  }

  void guardarDatos() {
    print("Estis son los cambios");
    print("Este es el nombre: ${tituloController.text}");
    print("Este es el nombre: ${_selectedDate}");
    print("Este es el nombre: ${ubicacionController.text}");
    print("Este es el nombre: ${descripcionController.text}");
    print("Este es el nombre: ${categoriaSeleccionada}");
    print("Este es el nombre: ${cuposdisponiblesContrroller.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Editar Evento'),
            Text('Modifica los detalles de tu evento',
                style: TextStyle(fontSize: 14)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                    time.minute,
                                  );
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
                              prefixIcon:
                                  const Icon(Icons.location_on_outlined)),
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
                                  .map((value) => DropdownMenuItem(
                                      value: value, child: Text(value)))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => categoriaSeleccionada = value),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Cupos Disponibles',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: cuposdisponiblesContrroller,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            suffixIcon: const Icon(Icons.confirmation_number),
                          ),
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
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      border:
                          Border(top: BorderSide(color: Colors.grey[300]!))),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Guardar lógica
                            //Navigator.pop(context);
                            guardarDatos();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                ),
              ],
            ),
    );
  }

  InputDecoration _inputDecoration({Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }
}
