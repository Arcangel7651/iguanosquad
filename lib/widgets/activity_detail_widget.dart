import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';

class ActivityDetailWidget extends StatelessWidget {
  final Activity activity;
  final bool isParticipating;
  final bool checkingParticipation;
  final int participantsCount;
  final VoidCallback onToggle;

  const ActivityDetailWidget({
    Key? key,
    required this.activity,
    required this.isParticipating,
    required this.checkingParticipation,
    required this.participantsCount,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActivityHeader(),
                const SizedBox(height: 24),
                _buildActivityInfo(),
                const SizedBox(height: 24),
                _buildActivityDescription(),
                const SizedBox(height: 24),
                _buildRequiredMaterials(),
                const SizedBox(height: 32),
                _buildParticipationButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          activity.nombre,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ),
        background: activity.urlImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    activity.urlImage!,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                color: Theme.of(context).primaryColor,
                child: const Center(
                  child: Icon(
                    Icons.nature_people,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildActivityHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Chip(
              avatar: Icon(
                activity.tipoActividad == 'Presencial'
                    ? Icons.location_on
                    : Icons.videocam,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                activity.tipoActividad ?? 'No especificado',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: activity.tipoActividad == 'Presencial'
                  ? Colors.green
                  : Colors.blue,
            ),
            const SizedBox(width: 8),
            if (activity.tipoCategoria != null)
              Chip(
                label: Text(activity.tipoCategoria!),
                backgroundColor: Colors.green[100],
                labelStyle: TextStyle(color: Colors.green[800]),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          activity.nombre,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (activity.fechaHora != null)
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd/MM/yyyy').format(activity.fechaHora),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        const SizedBox(height: 4),
        if (activity.fechaHora != null)
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                DateFormat('HH:mm').format(activity.fechaHora),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActivityInfo() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de la actividad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _infoRow(
              Icons.people,
              'Participantes',
              '$participantsCount${activity.disponibilidadCupos != null ? ' / ${activity.disponibilidadCupos}' : ''}',
            ),
            const Divider(),
            if (activity.ubicacion != null) ...[
              _infoRow(
                Icons.location_on,
                'Ubicación',
                activity.ubicacion!,
              ),
              const Divider(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityDescription() {
    if (activity.descripcion == null || activity.descripcion!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 0,
      color: const Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Descripción',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              activity.descripcion!,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequiredMaterials() {
    if (activity.materialesRequeridos == null ||
        activity.materialesRequeridos!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Materiales requeridos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              activity.materialesRequeridos!,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipationButton() {
    if (checkingParticipation) {
      return const Center(child: CircularProgressIndicator());
    }
    final bool noSpotsAvailable = activity.disponibilidadCupos != null &&
        participantsCount >= activity.disponibilidadCupos!;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: noSpotsAvailable && !isParticipating ? null : onToggle,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isParticipating ? Colors.red : const Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          isParticipating
              ? 'Cancelar participación'
              : noSpotsAvailable
                  ? 'No hay cupos disponibles'
                  : 'Participar en esta actividad',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
