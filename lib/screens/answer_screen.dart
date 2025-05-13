import 'package:flutter/material.dart';
import 'forum_screen.dart';  // Importamos para acceder a QuestionItem

class AnswerScreen extends StatefulWidget {
  final QuestionItem question;

  const AnswerScreen({super.key, required this.question});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final TextEditingController _answerController = TextEditingController();
  
  final List<Answer> _answers = [
    Answer(
      author: "María García",
      timePosted: "Hace 1 día",
      content: "Para compostar en un apartamento pequeño, te recomiendo un compostador de bokashi. Es un sistema cerrado que no genera olores y permite compostar casi todos los residuos de cocina. Solo necesitas agregar un acelerador especial y mantenerlo sellado. ¡Funciona muy bien en espacios reducidos!",
      likes: 3,
    ),
    Answer(
      author: "Carlos Ruiz",
      timePosted: "Hace 12 horas",
      content: "Yo uso un pequeño compostador de encimera con filtro de carbón activado. Lo importante es equilibrar bien los residuos secos (papel, cartón) con los húmedos (restos de frutas y verduras). Evita poner carnes o lácteos para prevenir olores. Si lo mantienes bien aireado y con la mezcla correcta, no tendrás problemas de olor.",
      likes: 2,
    ),
  ];

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Detalles de la Pregunta',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildQuestionDetail(),
                const Divider(height: 32),
                const Text(
                  'Respuestas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._answers.map(_buildAnswerItem).toList(),
              ],
            ),
          ),
          _buildAnswerInput(),
        ],
      ),
    );
  }

  Widget _buildQuestionDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 24,
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.question.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.question.author} · ${widget.question.timePosted}',
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
        const SizedBox(height: 16),
        Text(
          widget.question.content,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  widget.question.likes++;
                });
              },
              child: Row(
                children: [
                  Icon(Icons.thumb_up_alt_outlined, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    widget.question.likes.toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  widget.question.comments.toString(),
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnswerItem(Answer answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
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
                      answer.author,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      answer.timePosted,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            answer.content,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                answer.likes++;
              });
            },
            child: Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  answer.likes.toString(),
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
    );
  }

  Widget _buildAnswerInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                hintText: 'Escribe tu respuesta...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              if (_answerController.text.isNotEmpty) {
                setState(() {
                  _answers.add(
                    Answer(
                      author: 'Usuario',
                      timePosted: 'Justo ahora',
                      content: _answerController.text,
                      likes: 0,
                    ),
                  );
                  widget.question.comments++;
                  _answerController.clear();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

class Answer {
  final String author;
  final String timePosted;
  final String content;
  int likes;

  Answer({
    required this.author,
    required this.timePosted,
    required this.content,
    required this.likes,
  });
}