import 'package:flutter/material.dart';
import 'answer_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// Obtener la instancia de Supabase
final supabase = Supabase.instance.client;

class QuestionItem {
  final int id;
  final String title;
  final String author;
  final String timePosted;
  final String content;
  int likes;
  int comments;
  final String? userId;

  QuestionItem({
    required this.id,
    required this.title,
    required this.author,
    required this.timePosted,
    required this.content,
    required this.likes,
    required this.comments,
    this.userId,
  });

  // Método para crear un QuestionItem desde datos de Supabase
  static Future<QuestionItem> fromSupabase(Map<String, dynamic> data) async {
    // Obtener información del usuario que hizo la pregunta
    String authorName = 'Usuario';
    
    if (data['id_usuario'] != null) {
      try {
        final userData = await supabase
            .from('usuario')
            .select('nombre')
            .eq('id', data['id_usuario'])
            .single();
        
        if (userData != null && userData['nombre'] != null) {
          authorName = userData['nombre'];
        }
      } catch (e) {
        print('Error al obtener datos del usuario: $e');
      }
    }

    // Formatear la fecha para mostrar hace cuánto tiempo se publicó
    final DateTime fecha = DateTime.parse(data['fecha']);
    final String timePosted = _getTimeAgo(fecha);

    // Para likes y comentarios, podríamos obtenerlos de otras tablas si las tienes
    // Por ahora, los inicializamos en 0
    int likes = 0;
    int comments = 0;

    return QuestionItem(
      id: data['id_pregunta'],
      title: data['pregunta'],
      author: authorName,
      timePosted: timePosted,
      content: data['pregunta'], // Si no tienes un campo de contenido, puedes usar el mismo título
      likes: likes,
      comments: comments,
      userId: data['id_usuario'],
    );
  }

  // Método para formatear la fecha como "hace X tiempo"
  static String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return 'Hace ${(difference.inDays / 365).floor()} años';
    } else if (difference.inDays > 30) {
      return 'Hace ${(difference.inDays / 30).floor()} meses';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minutos';
    } else {
      return 'Justo ahora';
    }
  }
}

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  int _currentIndex = 2; // Start at the Preguntas tab
  int _selectedTabIndex = 0; // 0: Todas, 1: Mis Preguntas, 2: Por Responder
  
  List<QuestionItem> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  // Cargar preguntas desde Supabase
  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Obtener el usuario actual
      final currentUser = supabase.auth.currentUser;
      
      // Consultar según la pestaña seleccionada
      final query = supabase.from('preguntas').select('*');
      
      if (_selectedTabIndex == 1 && currentUser != null) {
        // Mis Preguntas - filtrar por id_usuario
        query.eq('id_usuario', currentUser.id);
      }
      // Para "Por Responder" necesitarías una tabla de respuestas y hacer un join
      // Para este ejemplo simplificado, mostraremos todas las preguntas en ese caso
      
      // Ordenar por fecha descendente (más recientes primero)
      query.order('fecha', ascending: false);
      
      final data = await query;
      
      // Convertir los datos en objetos QuestionItem
      final List<QuestionItem> loadedQuestions = [];
      for (var item in data) {
        final question = await QuestionItem.fromSupabase(item);
        loadedQuestions.add(question);
      }
      
      setState(() {
        _questions = loadedQuestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar las preguntas: $e';
        print(_errorMessage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preguntas y Respuestas',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Resuelve tus dudas sobre temas ecológicos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFFF1F9F1),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(0, 'Todas'),
                ),
                Expanded(
                  child: _buildTabButton(1, 'Mis Preguntas'),
                ),
                Expanded(
                  child: _buildTabButton(2, 'Por Responder'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _questions.isEmpty
                        ? const Center(child: Text('No hay preguntas disponibles'))
                        : RefreshIndicator(
                            onRefresh: _loadQuestions,
                            child: ListView.builder(
                              itemCount: _questions.length,
                              itemBuilder: (context, index) {
                                return _buildQuestionCard(_questions[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Eventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Mercado',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Preguntas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Mis Pub.',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          _showNewQuestionDialog(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
          _loadQuestions(); // Recargar preguntas al cambiar de pestaña
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuestionItem question) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnswerScreen(question: question),
          ),
        ).then((_) => _loadQuestions()); // Recargar al volver
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 20,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${question.author} · ${question.timePosted}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                question.content,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        question.likes.toString(),
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        question.comments.toString(),
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnswerScreen(question: question),
                        ),
                      ).then((_) => _loadQuestions()); // Recargar al volver
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Responder'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewQuestionDialog(BuildContext context) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Pregunta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Escribe tu pregunta aquí',
                labelText: 'Pregunta',
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                try {
                  // Obtener el usuario actual
                  final currentUser = supabase.auth.currentUser;
                  
                  // Insertar la nueva pregunta en Supabase
                  await supabase.from('preguntas').insert({
                    'pregunta': titleController.text,
                    'fecha': DateTime.now().toIso8601String().split('T')[0], // Formato YYYY-MM-DD
                    'id_usuario': currentUser?.id,
                  });
                  
                  // Recargar las preguntas
                  await _loadQuestions();
                  
                  Navigator.pop(context);
                } catch (e) {
                  // Mostrar un error si falla la inserción
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al publicar la pregunta: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }
}