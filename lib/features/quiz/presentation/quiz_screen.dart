import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'quiz_controller.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final TextEditingController _textController = TextEditingController();

  // Cores baseadas na imagem
  final Color bgColor = const Color(0xFF005662);
  final Color orangeColor = const Color(0xFFFF9800);
  final Color yellowColor = const Color(0xFFFFEB3B);
  final Color lightGreen = const Color(0xFFA5D6A7);
  final Color brightGreen = const Color(0xFF69F0AE);
  final Color lightRed = const Color(0xFFEF9A9A); // Para erro
  final Color blueButton = const Color(0xFF4285F4);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      ref.read(quizControllerProvider.notifier).submitAnswer(text);
      _textController.clear();
      FocusScope.of(context).unfocus(); // fecha o teclado
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizStateAsync = ref.watch(quizControllerProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'ChinêsOnline',
          style: GoogleFonts.lobster(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: quizStateAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (error, stack) => Center(
          child: Text(
            'Erro: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        data: (quizState) {
          if (quizState.isFinished) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Rodada Finalizada!'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(quizControllerProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Nova Rodada'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final question = quizState.currentQuestion;
          if (question == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Nenhum ideograma recebido do servidor para este nível.\\nPor favor, verifique se o banco de dados tem registros.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header com Pontuação
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    color: bgColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hugo Norte', // Aqui depois pode ser pego do Auth
                                style: GoogleFonts.getFont(
                                  'Vend Sans',
                                  color: const Color(0xFFFFEEAA),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'MAIOR SCORE HISTÓRICO'.tr(),
                                style: GoogleFonts.getFont(
                                  'Sansation',
                                  color: const Color.fromARGB(
                                    255,
                                    245,
                                    245,
                                    245,
                                  ),
                                  fontWeight: FontWeight.w300,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '${quizState.maxScore}',
                                style: GoogleFonts.getFont(
                                  'Vend Sans',
                                  color: const Color(0xFFFFEEAA),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'SCORE'.tr(),
                                    style: GoogleFonts.getFont(
                                      'Sansation',
                                      color: const Color(0xFFFFEEAA),
                                      fontWeight: FontWeight.w300,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '${quizState.currentScore}',
                                    style: GoogleFonts.getFont(
                                      'Vend Sans',
                                      color: const Color(0xFFD5FFF6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 40,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'NÍVEL'.tr(),
                                    style: GoogleFonts.getFont(
                                      'Sansation',
                                      color: const Color(0xFFFFEEAA),
                                      fontWeight: FontWeight.w300,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '${quizState.session?.level ?? 4}',
                                    style: GoogleFonts.getFont(
                                      'Vend Sans',
                                      color: const Color(0xFFD5FFF6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pergunta
                  Text(
                    'Que ideograma é esse?'.tr(),
                    style: GoogleFonts.getFont(
                      'Sansation',
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Card do Ideograma
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          question.character,
                          style: const TextStyle(
                            fontSize: 80,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campo de Input e Botão Enviar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            child: TextField(
                              controller: _textController,
                              style: GoogleFonts.getFont(
                                'Vend Sans',
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                              enabled: !quizState
                                  .isChecking, // Bloqueia durante checagem
                              decoration: InputDecoration(
                                hintText: 'Digite aqui o pin yin'.tr(),
                                hintStyle: GoogleFonts.getFont(
                                  'Vend Sans',
                                  color: Colors.black38,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              onSubmitted: (_) => _submit(),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: quizState.isChecking ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blueButton,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                            ),
                            child: Text(
                              'Enviar'.tr(),
                              style: GoogleFonts.getFont(
                                'Vend Sans',
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mostrar feedback dinamicamente apenas quando estiver checando
                  if (quizState.isChecking) ...[
                    // Chip de Pontuação (+20 pts)
                    if (quizState.isCorrect)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: brightGreen, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+ 20 pts'.tr(),
                          style: TextStyle(
                            color: brightGreen,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Card de Feedback de Acerto/Erro
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: quizState.isCorrect ? lightGreen : lightRed,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black87, width: 1),
                        ),
                          child: Stack(
                            children: [
                              if (quizState.isCorrect)
                                const Align(
                                  alignment: Alignment.topRight,
                                  child: Icon(
                                    Icons.volume_up,
                                    color: Colors.black87,
                                  ),
                                ),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      quizState.isCorrect
                                          ? 'Correto!'.tr()
                                          : 'Incorreto!'.tr(),
                                      style: GoogleFonts.getFont(
                                        'Vend Sans',
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      quizState.currentQuestion?.character ?? '',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 28,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      quizState.currentQuestion?.pinyin ?? '',
                                      style: GoogleFonts.getFont(
                                        'Vend Sans',
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      quizState.currentQuestion?.translation ?? '',
                                      style: GoogleFonts.getFont(
                                        'Vend Sans',
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w300,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
