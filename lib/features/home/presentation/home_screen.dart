import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ChinêsOnline',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black, // Fundo do header
        toolbarHeight: 50, // Altura exata de 50px
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black, // Cor de fundo da Safe Area (Status Bar)
          statusBarIconBrightness: Brightness.light, // Ícones do sistema (bateria, relógio) em branco (Android)
          statusBarBrightness: Brightness.dark, // Ícones do sistema em branco (iOS)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // TODO: Abrir menu lateral ou modal
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.1, 1.0],
            colors: [
              Color.fromRGBO(4, 99, 112, 1),
              Color.fromRGBO(16, 120, 161, 1),
              Color.fromRGBO(6, 69, 56, 1),
            ],
          ),
        ),
        child: const Center(
          child: Text(
            'O APP NAO RECOMPILOU',
            style: TextStyle(
              fontSize: 32,
              color: Colors.white, // Alterei para branco para melhor contraste
            ),
          ),
        ),
      ),
    );
  }
}
