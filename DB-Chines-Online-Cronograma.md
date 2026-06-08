# Cronograma Geral do Projeto ChinesOnline (MVP)
- **Fase 1:** Infraestrutura & Fundação (Semana 1)
- **Fase 2:** Backend API - CRUD e Auth (Semanas 2-3)
- **Fase 3:** Frontend Administrativo (Semana 4)
- **Fase 4:** Backend API - Game Engine (Semana 5)
- **Fase 5:** O Aplicativo Flutter - MVP (Semanas 6-8)
- **Fase 6:** Anti-Cheat & Deploy (Semanas 9-10)

---

# Tarefas Detalhadas: Banco de Dados Postgres (Neon)

## Fase 1: Infraestrutura (Configuração Inicial)
- [ ] **Provisionamento do Banco no Neon Tech**
  - [ ] Criar conta no Neon e inicializar um novo projeto PostgreSQL.
  - [ ] Criar o banco de dados `chinesonline_prod`.
  - [ ] Habilitar funcionalidade de Branching (opcional, para separar prod e dev).
  - [ ] Obter a *Connection String* padrão (URL de conexão).
- [ ] **Configuração de Performance (Connection Pooling)**
  - [ ] Habilitar e copiar a URL do Connection Pooler do Neon (ex: PgBouncer) para evitar que o Cloud Run esgote as conexões do banco ao escalar rapidamente.

## Fase 2: Backend API (Modelagem de Dados)
- [ ] **Estruturação do Schema (Migrations)**
  - [ ] Criar as tabelas base rodando scripts SQL ou via ORM (GORM migrations):
    - [ ] `users`: `id` (UUID), `firebase_uid` (String única), `name`, `email`, `max_score` (Integer, default 0), `created_at`.
    - [ ] `ideograms`: `id` (Serial/UUID), `character` (String), `pinyin` (String), `translation` (String), `level` (Int, 1-8), `wrong_options` (JSONB, apenas para Nível 1 e 2).
    - [ ] Índices na tabela `ideograms` pelo campo `level` para acelerar o sorteio de questões no Cloud Run.

## Fase 4: Game Engine (Tabelas Analíticas e Sessões)
- [ ] **Rastreamento de Sessões e Anti-Cheat**
  - [ ] Tabela `quiz_sessions`: `id` (UUID), `user_id` (FK), `level_played`, `started_at` (Timestamp), `completed_at` (Timestamp, nullable), `score_achieved` (Int).
  - [ ] (Opcional MVP) Tabela `user_answers`: Armazenar a resposta dada a cada ideograma para montar gráficos no painel de administração futuramente (ajuda a descobrir quais ideogramas os alunos mais erram).
- [ ] **Testes de Carga (Otimização)**
  - [ ] Verificar se as consultas da rota `GET /sessions/new` (que busca X registros aleatórios filtrados por nível) estão performáticas. (O `ORDER BY RANDOM() LIMIT 10` do Postgres pode ser pesado se a tabela crescer, pode ser necessário criar uma função customizada).
