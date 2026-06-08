# Cronograma Geral do Projeto ChinesOnline (MVP)
- **Fase 1:** Infraestrutura & Fundação (Semana 1)
- **Fase 2:** Backend API - CRUD e Auth (Semanas 2-3)
- **Fase 3:** Frontend Administrativo (Semana 4)
- **Fase 4:** Backend API - Game Engine (Semana 5)
- **Fase 5:** O Aplicativo Flutter - MVP (Semanas 6-8)
- **Fase 6:** Anti-Cheat & Deploy (Semanas 9-10)

---

# Tarefas Detalhadas: Aplicativo Mobile em Flutter

## Fase 5: O Aplicativo Flutter - MVP
- [ ] **Setup e Arquitetura**
  - [ ] `flutter create chinesonline`.
  - [ ] Configurar o **Riverpod** para gerência de estado.
  - [ ] Configurar o **GoRouter** para navegação.
  - [ ] Criar a estrutura de pastas Feature-First (`lib/features/`, `lib/core/`).
  - [ ] Importar paleta de cores e tipografias baseadas no design feito no Figma.
- [ ] **Autenticação Firebase**
  - [ ] Instalar `firebase_core` e `firebase_auth`.
  - [ ] Desenvolver telas do Figma: Splash Screen, Login, e Cadastro.
  - [ ] Sincronizar estado de usuário (Logado/Deslogado) com o GoRouter para proteger a Home do App.
- [ ] **Integração com API Go (Dio/Http)**
  - [ ] Configurar o cliente HTTP (ex: pacote `dio`).
  - [ ] Criar Interceptors para injetar o Token do Firebase Auth em toda requisição ao backend.
- [ ] **Home & Perfil do Usuário**
  - [ ] Desenvolver UI da Home com o progresso do usuário e o seu `max_score`.
  - [ ] Botão de "Jogar Nível X".
- [ ] **O Motor do Quiz (Gameplay 100% Local)**
  - [ ] Criar o serviço `QuizRepository` para buscar `GET /sessions/new`.
  - [ ] Construir o **StateNotifier (Riverpod)** para gerenciar a sessão localmente (Index da Pergunta Atual, Pontos Temporários, Respostas Dadas).
  - [ ] **UI: Nível 1-2 (Múltipla Escolha)**: Criar os cards/botões de múltipla escolha.
  - [ ] **UI: Nível 3+ (Teclado Pinyin)**: Criar tela de input de texto amigável.
- [ ] **Lógica de Feedback Visual (Hashing Local)**
  - [ ] Quando o usuário responder, aplicar a função Dart: `sha256(resposta_dada + salt_da_api)`.
  - [ ] Se bater com o `correct_hash` da API: piscar Verde.
  - [ ] Se errar: piscar Vermelho e mostrar a correção (se aplicável ao design).
- [ ] **Término e Envio da Rodada**
  - [ ] Ao terminar a questão 10, construir o JSON com o array de repostas e dar `POST /submit`.
  - [ ] Desenvolver tela de Game Over mostrando o resultado validado que retornou da API e atualização de Recorde.

## Fase 6: Anti-Cheat & Deploy
- [ ] **Firebase App Check**
  - [ ] Instalar pacote `firebase_app_check`.
  - [ ] Inicializar o App Check no `main.dart` ativando provedores do Play Integrity e App Attest.
  - [ ] Injetar o Token do App Check no cliente HTTP (`dio`) para mandar pra API Go.
- [ ] **SSL Pinning**
  - [ ] Extrair a chave pública (certificado) da API Go em produção.
  - [ ] Configurar o cliente HTTP do Flutter para rejeitar conexões que não batam com esse certificado (evitando ataques man-in-the-middle).
- [ ] **Build Obfuscation e Lojas**
  - [ ] Configurar ícones e nome do App (ChinesOnline).
  - [ ] Android: Rodar `flutter build aab --obfuscate --split-debug-info=/<dir>`.
  - [ ] iOS: Configurar Signing no Xcode e rodar build.
  - [ ] Enviar para as lojas.
