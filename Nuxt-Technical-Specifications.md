# Technical Specification - ChinesOnline (Admin Frontend)

## Executive Summary

Este documento foi gerado pelo agente **@pm** e serve como o guia arquitetural para a equipe que construirá o **Painel Administrativo** do sistema **ChinesOnline**. Este módulo será uma aplicação Web independente baseada no framework **Nuxt (Vue.js)**. Ele acessará a mesma API REST (escrita em Go) e o mesmo banco de dados PostgreSQL do ecossistema principal. 

O foco deste painel é fornecer **alta produtividade em operações de Data Entry** (cadastro de caracteres chineses, Pinyin, opções) e **gestão confortável do sistema** em telas grandes (Desktop).

---

## 1. Tech Stack & Infrastructure

- **Framework**: Nuxt 4 (ou Nuxt 3 com features atualizadas).
- **Linguagem**: TypeScript Strict Mode.
- **Estilização**: Tailwind CSS. Opcional: Uso de uma biblioteca de componentes robusta como Nuxt UI ou Shadcn-Vue para acelerar a construção de formulários pesados e tabelas de dados.
- **Consumo de API**: `useFetch` nativo do Nuxt (ofetch).
- **Hospedagem Recomendada**: Hospedagem estática, Vercel ou instâncias serverless comuns para painéis SPA/SSG.

---

## 2. Fluxo de Acesso e Segurança

### 2.1 Autenticação
- A autenticação deverá ser realizada via SDK do **Firebase Auth para Web**.
- O painel deve suportar login via Email/Senha (ou os provedores ativados no projeto).

### 2.2 Middleware de Rotas (RBAC)
- O sistema de rotas do Nuxt (`defineNuxtRouteMiddleware`) deve validar se o usuário autenticado possui privilégios de Administrador.
- Isso é feito avaliando as **Firebase Custom Claims** do token JWT do usuário (`admin: true`). Se não for administrador, o painel deve redirecionar forçadamente para fora, impedindo qualquer carregamento de dados (Unauthorized Error).

---

## 3. Funcionalidades Core (Operações Administrativas)

O painel deve consumir a API REST em Go nas rotas `/api/v1/admin/*`.

### 3.1 Gestão de Ideogramas (CRUD Principal)
- **Dashboard/Tabela**: Interface rica para listar, buscar e filtrar todos os ideogramas já cadastrados, ordenados por nível de dificuldade ou data de criação.
- **Formulário de Cadastro/Edição**: 
  - Input para o Caracter em Chinês.
  - Input para o Pinyin correspondente (deve aceitar a transcrição correta de tons fonéticos).
  - Seleção do Nível de Dificuldade (1 a 8).
  - Inputs para "Opções Incorretas de Múltipla Escolha" (exclusivo para quando o nível selecionado for 1 ou 2, para compor as 4 opções obrigatórias da tela do usuário).

### 3.2 Gestão de Usuários
- **Listagem e Auditoria**: Visualizar a lista de todos os usuários cadastrados na plataforma e seus respectivos recordes (`max_score`).
- **Ações Rápidas**: Capacidade de bloquear/banir usuários (status inativo) em casos de identificação de comportamentos suspeitos.

### 3.3 Dashboard Estatístico (Visão Geral)
- Gráficos consumindo relatórios de uso da API Go, exibindo:
  - Ideogramas com maior índice de erros (para ajustar a curva de aprendizado).
  - Número de sessões ativas por dia.
  - Ranking Global de Scores dos alunos (Leaderboard).

---

## 4. Conforto e Ergonomia
Como a inserção de caracteres ideográficos orientais exige atenção:
- Formulários devem possuir validações de schema estritas (Zod/Vee-Validate) antes de enviar o payload via API.
- Teclas de atalho para "Salvar e Cadastrar Novo" devem ser implementadas para facilitar o cadastro contínuo de baterias de 50 a 100 caracteres.
- A interface deve responder de forma clara a casos de sucesso ou erro (Toasts) provenientes de reações do Backend em Go.
