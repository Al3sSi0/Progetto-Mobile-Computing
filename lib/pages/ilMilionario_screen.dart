import 'package:corner/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:corner/structure.dart';
import 'package:corner/milionario/question_model.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  List<Question> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyQuestions();
  }

  Future<void> _loadDailyQuestions() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('daily_challenges')
          .doc(today)
          .get();

      if (doc.exists) {
        List<dynamic> data = doc['questions'];
        setState(() {
          questions = data.map((q) => Question.fromMap(q)).toList();
          questions.sort((a, b) => a.difficulty.compareTo(b.difficulty));
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Errore nel caricamento: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _checkAnswer(int selectedIndex) {
    bool isCorrect =
        selectedIndex == questions[currentQuestionIndex].correctIndex;

    if (isCorrect) {
      setState(() {
        score += 100 * (currentQuestionIndex + 1);
        if (currentQuestionIndex < questions.length - 1) {
          currentQuestionIndex++;
        } else {
          _showWinDialog();
        }
      });
    } else {
      _showGameOverDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "COMPLIMENTI, HAI VINTO!",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              child: Text(
                "GIOCA ANCORA",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colore_barra,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "PECCATO, HAI PERSO!",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              child: Text(
                "RIPROVA",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colore_barra,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    if (questions.isEmpty)
      return Scaffold(body: Center(child: Text("Nessun quiz oggi!")));

    final currentQuestion = questions[currentQuestionIndex];
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(systemNavigationBarColor: colore_barra),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                const Color.fromARGB(255, 47, 129, 55),
                colore_barra,
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 0.03 * screenHeight,
                  child: IconButton(
                    icon: const Icon(Icons.home),
                    color: colore_barra,
                    iconSize: 40,
                    onPressed: () {
                      Navigator.pop(
                        context,
                        MaterialPageRoute(builder: (_) => Home()),
                      );
                      ;
                    },
                  ),
                ),

                Positioned(
                  top: 0.12 * screenHeight,
                  width: screenWidth,
                  child: Center(
                    child: Text(
                      "SCALATA AL MILIONE - DOMANDA ${currentQuestionIndex + 1}/10",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Instagram Sans',
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 140, 8, 8),
                        letterSpacing: 1,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.2 * screenHeight,
                  left: 20,
                  right: 20,
                  child: Card(
                    color: colore_sfondo1,
                    elevation: 15,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        currentQuestion.text,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colore_barra,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 0.35 * screenHeight,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor: colore_sfondo1,
                          ),
                          onPressed: () => _checkAnswer(index),
                          child: Text(
                            currentQuestion.options[index],
                            style: TextStyle(
                              fontFamily: 'Instagram Sans',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: colore_barra,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Positioned(
                  bottom: 0.15 * screenHeight,
                  width: screenWidth,
                  child: Center(
                    child: Text(
                      "Punteggio attuale: €$score",
                      style: TextStyle(
                        fontFamily: 'Instagram Sans',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
