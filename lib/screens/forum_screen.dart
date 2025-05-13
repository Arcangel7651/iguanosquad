import 'package:flutter/material.dart';
import 'package:iguanosquad/screens/answer_screen.dart';
import 'package:iguanosquad/widgets/question_card.dart';
import 'package:iguanosquad/widgets/new_question_dialog.dart';
import 'package:iguanosquad/models/Preguntas.dart';
import 'package:iguanosquad/services/preguntas_service.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final _service = PreguntasService();
  List<Pregunta> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllQuestions();
  }

  Future<void> _loadAllQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final preguntas = await _service.obtenerTodasLasPreguntas();
      setState(() => _questions = preguntas);
    } catch (e) {
      setState(() => _errorMessage = 'Error cargando preguntas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ya no ponemos appBar aquí...
      body: RefreshIndicator(
        onRefresh: _loadAllQuestions,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Foro de Preguntas'),
                background: Container(
                  color: Theme.of(context).primaryColor,
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(5),
                  child: const Text(
                    'Resuelve tus dudas sobre temas ecológicos',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            if (_isLoading)
              SliverFillRemaining(
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (_questions.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No hay preguntas disponibles')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final pregunta = _questions[i];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnswerScreen(
                              question: _questions[i],
                            ),
                          ),
                        );
                      },
                      child: QuestionCard(question: pregunta),
                    );
                  },
                  childCount: _questions.length,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => NewQuestionDialog(
              onSubmit: (texto) async {
                await _service.crearPregunta(texto);
                await _loadAllQuestions();
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
