# Cronograma Geral do Projeto ChinesOnline (MVP)
- **Fase 1:** Infraestrutura & Fundação (Semana 1)
- **Fase 2:** Backend API - CRUD e Auth (Semanas 2-3)
- **Fase 3:** Frontend Administrativo (Semana 4)
- **Fase 4:** Backend API - Game Engine (Semana 5)
- **Fase 5:** O Aplicativo Flutter - MVP (Semanas 6-8)
- **Fase 6:** Anti-Cheat & Deploy (Semanas 9-10)

---

# Tarefas Detalhadas: Firebase

## Fase 1: Setup do Firebase
- [ ] **Criação do Projeto**
  - [ ] Criar projeto no Firebase Console (pode ser atrelado ao mesmo projeto do Google Cloud criado anteriormente).
  - [ ] Registrar 3 aplicativos dentro do projeto Firebase: 
    - 1 App Web (Para o Painel Nuxt Administrativo).
    - 1 App Android (Para o Flutter).
    - 1 App iOS (Para o Flutter).
- [ ] **Configuração do Firebase Auth**
  - [ ] Habilitar provedores de Autenticação (E-mail/Senha e Google Sign-in).
  - [ ] Adicionar os domínios permitidos (localhost, domínio do Vercel/Nuxt).
- [ ] **Integração Go-Firebase (Service Account)**
  - [ ] Acessar configurações de Serviço e gerar uma nova chave primária JSON (Service Account Key).
  - [ ] Guardar essa chave com segurança para ser consumida pela API em Go no Google Cloud Run (ela é que dá o poder do Go verificar se o token do usuário é válido).

## Fase 3 e Fase 5: Implementação de Custom Claims (RBAC)
- [ ] **Criação de Usuários Administradores**
  - [ ] Como o Firebase Console não tem um botão para adicionar a flag `admin: true` a um usuário, será necessário criar um script rápido (em Node ou no próprio Go) usando a Admin SDK para injetar essa "Custom Claim" no seu e-mail pessoal, garantindo que você consiga fazer o login inicial no painel do Nuxt.

## Fase 6: Firebase App Check (A Blindagem Final)
- [ ] **Ativação e Registro das Chaves**
  - [ ] Acessar o console do Firebase > App Check.
  - [ ] **Android**: Configurar o **Play Integrity API**. Vincular ao seu aplicativo na Google Play Console e associar os certificados SHA-256 de produção.
  - [ ] **iOS**: Configurar o **DeviceCheck** ou **App Attest** injetando a chave P8 da conta de desenvolvedor da Apple.
- [ ] **Acompanhamento no Backend**
  - [ ] A API do Go precisa da chave pública do Firebase para decodificar e validar se o tráfego do App Check veio mesmo de um dispositivo íntegro.
- [ ] **Ativação do Firebase Analytics (Opcional MVP)**
  - [ ] Ligar os dashboards básicos de analytics para ver engajamento dos alunos, telas mais acessadas e crash logs via Crashlytics.
