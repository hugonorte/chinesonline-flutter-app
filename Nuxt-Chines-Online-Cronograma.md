# Cronograma Geral do Projeto ChinesOnline (MVP)
- **Fase 1:** Infraestrutura & Fundação (Semana 1)
- **Fase 2:** Backend API - CRUD e Auth (Semanas 2-3)
- **Fase 3:** Frontend Administrativo (Semana 4)
- **Fase 4:** Backend API - Game Engine (Semana 5)
- **Fase 5:** O Aplicativo Flutter - MVP (Semanas 6-8)
- **Fase 6:** Anti-Cheat & Deploy (Semanas 9-10)

---

# Tarefas Detalhadas: Frontend Administrativo em Nuxt

## Fase 3: Frontend Administrativo (Desenvolvimento Core)
- [ ] **Setup Inicial do Projeto**
  - [ ] Criar projeto Nuxt 4 (ou 3).
  - [ ] Instalar e configurar Tailwind CSS (ou Tailwind UI/Nuxt UI).
  - [ ] Configurar arquivos de variáveis de ambiente apontando para a API Go.
- [ ] **Integração Firebase Auth (Client-Side)**
  - [ ] Instalar Firebase JS SDK (`firebase/app` e `firebase/auth`).
  - [ ] Desenvolver a página de Login (`/login`).
  - [ ] Criar Plugin Nuxt para escutar o estado de autenticação (`onAuthStateChanged`).
  - [ ] Extrair o token JWT via `user.getIdToken()` para injetar nas requisições da API.
- [ ] **Sistema de Roteamento e Proteção (RBAC)**
  - [ ] Criar o middleware global `auth.ts` para redirecionar usuários não logados para `/login`.
  - [ ] No middleware, verificar as claims do usuário (`getIdTokenResult()`) para garantir que ele tenha a tag `admin: true`.
- [ ] **Dashboard e UX/UI**
  - [ ] Desenvolver Layout administrativo base (Sidebar, Header, Profile).
  - [ ] Configurar composables/interceptors customizados do `$fetch` para anexar o Bearer Token do Firebase automaticamente a todas as requisições para a API em Go.
- [ ] **Módulo: Gestão de Ideogramas**
  - [ ] Desenvolver a **Página de Listagem** (`/ideograms`) com tabelas.
  - [ ] Integrar endpoint `GET /api/v1/admin/ideograms`.
  - [ ] Criar botões de "Editar" e "Deletar".
  - [ ] Desenvolver a **Página de Cadastro/Edição** (`/ideograms/new`).
  - [ ] Criar formulário focado em **Data Entry Produtivo**:
    - [ ] Campo para o Caracter.
    - [ ] Campo para o Pinyin.
    - [ ] Campo de Tradução.
    - [ ] Select de Dificuldade (1 a 8).
    - [ ] **Lógica Dinâmica**: Se a dificuldade for 1 ou 2, abrir três campos obrigatórios para "Opções Incorretas" (para alimentar a múltipla escolha no App).
- [ ] **Módulo: Gestão de Usuários**
  - [ ] Desenvolver a tabela de listagem de usuários.
  - [ ] Consumir endpoint `GET /api/v1/admin/users`.
  - [ ] Mostrar o recorde de pontos de cada usuário (`max_score`).

## Fase 6: Deploy
- [ ] Gerar build estático ou server-side dependendo da escolha final (`npx nuxt generate` ou `npx nuxt build`).
- [ ] Configurar a Vercel, Netlify ou Firebase Hosting.
- [ ] Setar as variáveis de ambiente de produção (URL da API Go em Prod e chaves do Firebase).
