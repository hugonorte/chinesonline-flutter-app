import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinesonline/features/auth/data/auth_repository.dart';
import 'package:chinesonline/features/auth/data/auth_provider.dart';
import 'package:chinesonline/features/auth/domain/country.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  DateTime? _selectedBirthDate;
  int _selectedCountryId = 26; // Default: Brasil
  bool _isLoading = false;

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  String _formatDateForApi(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T00:00:00Z";
  }

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, informe seu nome.')));
      return;
    }
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, informe sua data de nascimento.')));
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('As senhas não coincidem.')));
      return;
    }
    
    ref.read(isRegisteringProvider.notifier).setState(true);
    setState(() => _isLoading = true);
    try {
      // 1. Criar usuário no Firebase
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Sincronizar com o backend Go
      if (cred.user != null) {
        final birthDateStr = _formatDateForApi(_selectedBirthDate!);
        await authRepository.syncUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          country: _selectedCountryId,
          accountType: 0, // 0 = Free
          birthDate: birthDateStr,
        );
      }
      
      // Sucesso
      if (mounted) {
        final overlay = Overlay.of(context);
        final overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('SUCESSO', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Seu cadastro foi realizado com sucesso!', style: TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
                    SizedBox(height: 8),
                    Text('Você será redirecionado para o jogo em alguns segundos', style: TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        );
        overlay.insert(overlayEntry);

        await Future.delayed(const Duration(seconds: 2));
        overlayEntry.remove();
        
        if (mounted) {
          ref.read(isRegisteringProvider.notifier).setState(false);
          context.go('/quiz');
        }
      }
    } catch (e) {
      if (mounted) {
        ref.read(isRegisteringProvider.notifier).setState(false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no cadastro: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final countryOptions = countries.where((c) => c.id > 0).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.1, 1.0],
              colors: [
                Color.fromRGBO(112, 4, 4, 1),
                Color.fromRGBO(161, 16, 16, 1),
                Color.fromRGBO(69, 6, 6, 1),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ChinêsOnline',
                      style: GoogleFonts.lobster(fontSize: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cadastro',
                      style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Confirmar Senha',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickBirthDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data de Nascimento',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        ),
                        child: Text(
                          _selectedBirthDate == null 
                            ? 'Selecione uma data' 
                            : _formatDate(_selectedBirthDate!),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'País',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                      dropdownColor: const Color.fromRGBO(69, 6, 6, 1),
                      iconEnabledColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      initialValue: _selectedCountryId,
                      isExpanded: true,
                      items: countryOptions.map((c) {
                        return DropdownMenuItem<int>(
                          value: c.id,
                          child: Text('${c.flag} ${c.name}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCountryId = val);
                      },
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A7FFF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                            ),
                            child: const Text('Cadastrar', style: TextStyle(fontSize: 18)),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Já possui conta? Faça Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
