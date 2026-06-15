# Technical Specification - ChinesOnline (Mobile App)

## Executive Summary

Este documento serve como a "Fonte da Verdade" escrita pelo **@pm** para os agentes **@engineer** e **@qa**. O objetivo é construir o aplicativo móvel do **ChinesOnline** utilizando **Flutter**. O sistema utilizará uma arquitetura distribuída com um Backend em **Go (Google Cloud)** e um painel administrativo independente em **Flutter Web**. O foco central do app é entregar uma experiência gamificada ultrarrápida, de baixo custo em nuvem e **extremamente segura contra fraudes (Anti-Cheat)**.

---

## 1. Tech Stack & Infrastructure (App Mobile)

### 1.1 Framework Core
- **Framework**: Flutter.
- **Linguagem**: Dart.
- **Gerenciamento de Estado**: Riverpod (Recomendado) ou BLoC.
- **Roteamento**: GoRouter.

### 1.2 Integração com Backend e Serviços
- **Backend Principal**: API REST em Go (Golang) hospedada no Google Cloud Run.
- **Autenticação**: Firebase Authentication (Email/Senha, Google Sign-In). O Flutter envia o JWT do Firebase para a API em Go autorizar as requisições.
- **Analytics & Segurança**: Google Analytics for Firebase e **Firebase App Check** (Play Integrity / App Attest).

---

## 2. Core Game Loop & Economia de Infraestrutura

Para garantir jogabilidade fluida (sem loading entre perguntas) e economia massiva de recursos no Cloud Run, o aplicativo deve adotar uma abordagem baseada em **Lotes (Batches) e Gameplay Local**.

### 2.1 O Fluxo de Lotes (Sessions)
1. **Início da Rodada**: O Flutter requisita `GET /api/v1/sessions/new?level=X`. O servidor retorna um lote com 10-20 ideogramas e os metadados de segurança (salts e hashes).
2. **Gameplay 100% Local**: O usuário joga toda a rodada off-line/local. O app valida os acertos/erros usando os hashes (veja seção de Anti-Cheat) para dar feedback imediato de UI (verde/vermelho) sem fazer nenhuma requisição de rede.
3. **Fim da Rodada**: O Flutter compila as respostas brutas dadas pelo usuário e envia para `POST /api/v1/sessions/{id}/submit`.

---

## 3. Segurança e Anti-Cheat (Crucial)

O aplicativo é o cliente e **nunca deve ser confiado**. O pacote de segurança se divide em 5 pilares:

### 3.1 Feedback Imediato Seguro (Hashing com Salt por Questão)
Para que a tela brilhe verde ou vermelho na hora, o app precisa validar a resposta, mas **não pode** ter a resposta certa em texto plano na RAM (para evitar leitores de memória).
- **A Estratégia**: A API envia no lote um `salt` dinâmico e o `correct_hash` (ex: `SHA256(resposta_certa + salt)`). 
- **No Flutter**: O usuário escolhe/digita a resposta, o app concatena com o `salt` e faz o Hash. Se bater com o `correct_hash`, a UI reage positivamente.

### 3.2 Validação Server-Side Obrigatória
- O Flutter **jamais** calcula a própria pontuação ou envia ao backend algo como `{"pontos": 100}`.
- O payload de fechamento de sessão (`POST /submit`) contém apenas a ID da questão e a string exata que o usuário respondeu. O servidor Go irá "corrigir a prova", calcular os pontos de forma imutável e atualizar o banco de dados.

### 3.3 Proteção contra Time-Spoofing (Bots rápidos)
- O backend salvará a hora em que entregou o lote e a hora em que recebeu o `POST /submit`. 
- **O App não precisa fazer nada especial aqui**, apenas enviar as métricas de tempo gasto em cada questão. O servidor anulará rodadas onde 10 questões difíceis forem resolvidas em menos de 1 segundo (comportamento impossível para humanos).

### 3.4 Proteção contra Engenharia Reversa (App Check)
- É obrigatório configurar o pacote `firebase_app_check` no Flutter ativando o **Play Integrity** (Android) e **App Attest** (iOS). O token gerado deve ser incluído no header das chamadas para a API Go, garantindo que a requisição veio do app original compilado pela loja, e não de um script Python (Postman/cURL).

> [!IMPORTANT]
> **Atenção @engineer para Implementação do App Check:**
> 1. Adicione a dependência `firebase_app_check` no `pubspec.yaml`.
> 2. No `main.dart`, inicialize o App Check logo após o `Firebase.initializeApp()`:
>    ```dart
>    await FirebaseAppCheck.instance.activate(
>      androidProvider: AndroidProvider.playIntegrity,
>      appleProvider: AppleProvider.appAttest,
>    );
>    ```
>    *Dica: use `AndroidProvider.debug` durante o desenvolvimento local para não ser bloqueado.*
> 3. Em seu Http Client / Dio Interceptor global, você deve capturar o token em tempo real e anexá-lo ao header da requisição. Isso é **obrigatório** para todas as rotas do Game Engine (`/api/v1/sessions/*`).
>    ```dart
>    final appCheckToken = await FirebaseAppCheck.instance.getToken();
>    if (appCheckToken != null) {
>      options.headers['X-Firebase-AppCheck'] = appCheckToken;
>    }
>    ```

### 3.5 Proteção de Transporte (SSL Pinning)
- Para evitar ataques de *Man-In-The-Middle* (ex: Charles Proxy interceptando a API), o cliente Flutter deve implementar **SSL/Certificate Pinning** em seu client HTTP (ex: pacote `dio` ou `http`), aceitando apenas os certificados raiz do domínio da API em Go.

### 3.6 Obfuscação do Dart AOT
- O processo de build final para release deve incluir flags de obfuscação pesadas (ex: `flutter build apk --obfuscate --split-debug-info=/<dir>`) para dificultar a engenharia reversa do código que checa o Salt + Hash.

---

## 4. Shared Architectures

- `lib/core/`: Componentes globais, temas, utilitários de Hash, Dio/Http Client configurado com SSL Pinning e Interceptors (JWT Token + App Check Token).
- `lib/features/auth/`: Lógica de Autenticação.
- `lib/features/quiz/`: A engine do jogo, gerenciando o estado do lote, transições de tela e exibição de componentes diferentes para Múltipla Escolha (Nível 1-2) vs. Teclado Pinyin (Nível 3-8).

---

## 5. Fluxo de Autenticação e Registro de Login (Frontend ➔ Firebase ➔ Backend Go)

Esta seção detalha o fluxo arquitetural que o Frontend (App) deve seguir ao lidar com o cadastro e login do usuário, garantindo a sincronização correta com o banco de dados principal no Backend (PostgreSQL) e o registro de auditoria de logins (`LoginHistory`).

A premissa básica desta arquitetura é: **O Firebase gerencia a segurança e identidade, enquanto o Backend Go gerencia as regras de negócio e dados complementares.**

### 5.1 Workflow 1: Cadastro de Usuário
O fluxo de cadastro utiliza uma arquitetura baseada no Frontend ("Frontend-Driven Sync"), onde o app atua como orquestrador da sincronização de dados.

1. **Ação do Usuário**: O usuário preenche o formulário de cadastro no App (ex: E-mail, Senha, Nome, Nível de Chinês, Data de Nascimento).
2. **Integração Firebase**: O App chama o SDK do Firebase (`createUserWithEmailAndPassword`) enviando **apenas** o E-mail e a Senha. O Firebase não armazenará outros dados de negócio.
3. **Retorno do Firebase**: O Firebase cria a conta e retorna o `UID` (Identificador Único) e um **Token JWT** válido.
4. **Sincronização com o Backend (Go)**:
   - Imediatamente após receber o token do Firebase, o App faz uma chamada HTTP (ex: `POST /api/v1/users/sync` ou `POST /api/v1/users`) para o Backend Go.
   - **Header**: Envia o Token JWT do Firebase (`Authorization: Bearer <token_jwt>`).
   - **Body (JSON)**: Envia o restante dos dados do formulário (`nome`, `nivel`, `data_nascimento`).
5. **Processamento no Go**:
   - O Backend verifica a validade do Token JWT usando o Firebase Admin SDK e extrai o `UID` original.
   - O Backend realiza um **UPSERT** (Insert se não existir, Update se existir) na tabela `users` do PostgreSQL, garantindo que o usuário esteja registrado no banco com seu `firebase_uid` e todos os dados de negócio anexados.
   - **⚠️ ATENÇÃO (Race Condition)**: O App deve assegurar que a chamada `POST /api/v1/users/sync` seja concluída com sucesso ANTES de permitir que o roteador redirecione o usuário para telas internas (como `/quiz`). Redirecionamentos precoces com base apenas no estado do Firebase (e.g., escutando `authStateChanges`) causarão falhas nas chamadas subsequentes, pois o usuário ainda não estará completamente sincronizado no Backend Go. O Roteador só deve redirecionar o recém-cadastrado após a API em Go confirmar a sincronização (Status 200).

### 5.2 Workflow 2: Login Recorrente e Histórico de Login (`LoginHistory`)
Para auditoria e acompanhamento de sessões ativas, cada login deve gerar uma entrada na tabela `LoginHistory`. A tabela de `QuizSession` **não** é usada para esse propósito.

1. **Ação do Usuário**: O usuário insere as credenciais de login ou utiliza o Login Social (Google/Apple).
2. **Autenticação Firebase**: O App comunica-se com o Firebase, que autentica a requisição e devolve um **Token JWT** (IdToken) fresco e válido.
3. **Comunicação com o Backend (Registro de Login)**:
   - O App faz uma chamada HTTP específica (ex: `POST /api/v1/auth/login`) para avisar o backend do novo login.
   - **Header**: O App anexa o Token JWT (`Authorization: Bearer <token_jwt>`).
   - Opcionalmente, o App pode enviar metadados customizados no Body (ex: versão do App).
4. **Mecanismo Interno no Backend Go**:
   - O Backend valida o Token JWT usando o Firebase Admin SDK.
   - O Backend consulta a tabela `users` pelo `firebase_uid` extraído do token para obter o `ID` interno do usuário. *(Importante: Caso o usuário não seja encontrado no banco, o backend deve recriá-lo na hora, servindo como uma camada de redundância para falhas no fluxo de cadastro).*
   - O Backend intercepta dados brutos da conexão da requisição HTTP:
     - **IP**: Extraído do header de rede `X-Forwarded-For` ou do RemoteAddr da requisição.
     - **Device/Browser**: Extraído do header `User-Agent`.
   - O Backend insere uma nova linha na tabela `login_histories` com: `UserID`, `IPAddress`, `UserAgent` e a data exata do login.
   - Retorna sucesso (`200 OK`) para o App, confirmando que a sessão foi auditada e registrada na base central.

### 5.3 Contrato de APIs para o Frontend (Atenção Agentes 🤖)
> [!IMPORTANT]
> **Aos Agentes de Frontend (@engineer):**
> Para implementar os workflows acima, você deve realizar requisições HTTP (usando Dio ou http client) para as seguintes rotas da API em Go, garantindo que o token JWT do Firebase esteja sempre presente no header `Authorization: Bearer <token>`:
> 
> **1. Rota de Sincronização de Cadastro:**
> - **Endpoint:** `POST /api/v1/users/sync`
> - **Quando chamar:** Imediatamente após a criação de um novo usuário no Firebase via `createUserWithEmailAndPassword`.
> - **Payload Esperado (JSON):** `{"name": "...", "email": "...", "country": 0, "account_type": 0, "birth_date": "YYYY-MM-DDT00:00:00Z"}` *(Onde country e account_type são inteiros representando os índices dos Enums do backend)*.
> 
> **2. Rota de Histórico de Login:**
> - **Endpoint:** `POST /api/v1/auth/login`
> - **Quando chamar:** Sempre que ocorrer um evento de login bem-sucedido (Email/Senha ou Social Login) e/ou na inicialização do app caso haja uma sessão válida, garantindo o rastreamento do dispositivo e IP.
> - **Payload Esperado (JSON - Opcional):** `{"device": "iOS 17.2"}`

---

## Approval Gate

> [!IMPORTANT]
> **Atenção @engineer**
> Este documento representa o design final. O módulo administrativo foi isolado para outro projeto (Flutter Web) e o backend para um projeto em Go. Concentre-se 100% no consumo de APIs e nos pilares de segurança descritos.
> O backend em GO já está funcionando e está localizado em `/mnt/sda2/sandbox/chinesonline/backend` para uso de somente leitura. Nenhum agente aqui nesse repositório poderá fazer qualquer alteração ou escrita em `/mnt/sda2/sandbox/chinesonline/backend`.


## Cronograma - Fase 1: Infraestrutura (O Alicerce)

Nesta fase, o foco é configurar as fundações na nuvem. A ordem abaixo garante que os serviços dependentes sejam criados sequencialmente.

### Passo 1: A Fundação no Google Cloud (GCP)
- [X] Criar ou logar na sua conta do Google Cloud Platform.
- [X] Criar o projeto raiz (ex: `chinesonline-prod`).
- [X] Vincular uma conta de faturamento (Billing) ativa ao projeto.
- [X] *Quick Win*: Acessar o menu IAM e confirmar que seu usuário principal tem a role de "Owner".
- [X] **Configuração de Serviços Cloud (Apis)**
  Criação do serviço que emite um alerta pelo Telegram quando a conta chegar a um determinado valor.
  [LINK](https://developers.google.com/workspace/guides/create-project)
  [LINK](https://medium.com/@joaobrunomarinho/crie-alertas-customizados-com-telegram-e-google-cloud-platform-d671d5b32af9)
- [X] Criação do Bucket que será usado para armazenar os arquivos de mídia do curso (vídeos, áudio, imagem) no projeto.
  
### Passo 2: O Banco de Dados (Neon Tech / PostgreSQL)
- [X] Criar conta no Neon.tech.
- [X] Criar o projeto e inicializar o banco principal (`chinesonline_prod`).
- [X] *Quick Win*: Copiar a `Connection String` direta e salvá-la em um cofre de senhas local ou arquivo `.env` de rascunho.
- [X] *Quick Win*: Ativar o botão de "Connection Pooling" (PgBouncer) na dashboard do Neon e copiar essa segunda URL (que será a oficial usada pelo Cloud Run depois).

### Passo 3: Criação e Vínculo do Firebase
- [X] Acessar o Firebase Console e clicar em "Add Project".
- [X] **Crucial**: Selecionar o projeto GCP `chinesonline-prod` já existente para vinculá-los na mesma estrutura.
- [ ] *Quick Win*: Registrar a "casca" dos 3 aplicativos para já gerar os arquivos de configuração:
  - [X] App Web (Admin Flutter Web).
  - [ ] App Android (Flutter).
  - [ ] App iOS (Flutter).

### Passo 4: Configurando Autenticação Básica (Firebase Auth)
- [X] No menu lateral do Firebase, acessar "Authentication" e clicar em "Get Started".
- [X] Habilitar o provedor de **E-mail/Senha**.
- [X] Habilitar o provedor do **Google**.
- [X] *Quick Win*: Ir na aba "Settings > Authorized domains" do Auth e garantir que `localhost` esteja na lista, permitindo que você consiga testar o login no Flutter Web localmente amanhã.

### Passo 5: Geração da Chave Mestra para o Backend em Go
- [X] No Firebase, ir em "Project Settings" (engrenagem) > Aba "Service Accounts".
- [X] Selecionar o "Firebase Admin SDK" e clicar em "Generate new private key".
- [X] *Quick Win*: Fazer o download do arquivo JSON. Renomeie para algo claro (ex: `firebase-service-account.json`) e guarde-o em um local seguro. Ele será o "passaporte" que conectará o seu servidor Go ao Firebase na Fase 2.

  ## Fase 1: Infraestrutura (Configuração Inicial)
- [ ] **Provisionamento do Banco no Neon Tech**
  - [X] Criar conta no Neon e inicializar um novo projeto PostgreSQL.
  - [X] Criar o banco de dados `chinesonline_prod`.
  - [X] Habilitar funcionalidade de Branching (opcional, para separar prod e dev).
  - [X] Obter a *Connection String* padrão (URL de conexão).
- [ ] **Configuração de Performance (Connection Pooling)**
  - [X] Habilitar e copiar a URL do Connection Pooler do Neon (ex: PgBouncer) para evitar que o Cloud Run esgote as conexões do banco ao escalar rapidamente.


  ---

  ## Fase 2: Backend API (Modelagem de Dados)
- [ ] **Estruturação do Schema (Migrations)**
  - [X] Criar as tabelas base rodando scripts SQL ou via ORM (GORM migrations):
    - [X] `users`: `id` (UUID), `firebase_uid` (String única), `name`, `email`, `max_score` (Integer, default 0), `created_at`.
    - [X] `ideograms`: `id` (Serial/UUID), `character` (String), `pinyin` (String), `translation` (String), `level` (Int, 1-8), `wrong_options` (JSONB, apenas para Nível 1 e 2).
    - [X] Índices na tabela `ideograms` pelo campo `level` para acelerar o sorteio de questões no Cloud Run.

    ## Fase 2: Backend API - CRUD e Auth
- [ ] **Setup Inicial do Projeto**
  - [X] Inicializar o módulo (`go mod init`).
  - [X] Instalar framework web (Gin, Fiber ou Echo).
  - [X] Instalar biblioteca do banco de dados (GORM ou sqlc).
  - [X] Configurar leitura de variáveis de ambiente (`.env`).
- [ ] **Conexão com Banco de Dados**
  - [X] Criar arquivo de conexão para o Neon (PostgreSQL).
  - [X] Configurar Connection Pooling.
- [ ] **Integração Firebase Auth (Middleware)**
  - [X] Instalar Firebase Admin SDK para Go.
  - [X] Carregar a Service Account Key do Firebase via env vars.
  - [X] Criar o middleware `VerifyJWT` para proteger rotas.
  - [X] Criar o middleware `VerifyAdmin` que decodifica o JWT e valida se `admin: true`.
- [ ] **Rotas do Módulo Administrativo (Protegidas por VerifyAdmin)**
  - [X] `POST /api/v1/admin/ideograms`: Cadastro de novos ideogramas.
  - [X] `PUT /api/v1/admin/ideograms/:id`: Atualização de Pinyin, traduções e nível.
  - [X] `GET /api/v1/admin/ideograms`: Listagem com paginação e filtros.
  - [X] `DELETE /api/v1/admin/ideograms/:id`: Remoção lógica (soft delete).
  - [X] `GET /api/v1/admin/users`: Listagem de usuários cadastrados e seus `max_score`.

  ---

  ## Fase 3 e Fase 5: Implementação de Custom Claims (RBAC)
- [ ] **Criação de Usuários Administradores**
  - [X] Como o Firebase Console não tem um botão para adicionar a flag `admin: true` a um usuário, será necessário criar um script rápido (em Node ou no próprio Go) usando a Admin SDK para injetar essa "Custom Claim" no seu e-mail pessoal, garantindo que você consiga fazer o login inicial no painel do Flutter Web.


## Fase 3: Frontend Administrativo (Desenvolvimento Core)
- [ ] **Setup Inicial do Projeto**
  - [X] Criar projeto Flutter Web.
  - [X] Instalar e configurar Material Design.
  - [X] Configurar arquivos de variáveis de ambiente apontando para a API Go.
- [ ] **Integração Firebase Auth (Client-Side)**
  - [X] Instalar pacote `firebase_auth`.
  - [X] Desenvolver a página de Login (`/login`).
  - [X] Criar Provider do Riverpod para escutar o estado de autenticação (`authStateChanges`).
  - [X] Extrair o token JWT via `user.getIdToken()` para injetar nas requisições da API.
- [X] **Sistema de Roteamento e Proteção (RBAC)**
  - [X] Criar o middleware global `auth.ts` para redirecionar usuários não logados para `/login`.
  - [X] No middleware, verificar as claims do usuário (`getIdTokenResult()`) para garantir que ele tenha a tag `admin: true`.
- [ ] **Dashboard e UX/UI**
  - [X] Desenvolver Layout administrativo base (Sidebar, Header, Profile).
  - [X] Configurar composables/interceptors customizados do `$fetch` para anexar o Bearer Token do Firebase automaticamente a todas as requisições para a API em Go.
- [ ] **Módulo: Gestão de Ideogramas**
  - [X] Desenvolver a **Página de Listagem** (`/ideograms`) com tabelas.
  - [X] Integrar endpoint `GET /api/v1/admin/ideograms`.
  - [X] Criar botões de "Editar" e "Deletar".
  - [X] Desenvolver a **Página de Cadastro/Edição** (`/ideograms/new`).
  - [X] Criar formulário focado em **Data Entry Produtivo**:
    - [X] Campo para o Caracter.
    - [X] Campo para o Pinyin.
    - [X] Campo de Tradução.
    - [X] Select de Dificuldade (1 a 8).
    - [X] **Lógica Dinâmica**: Se a dificuldade for 1 ou 2, abrir três campos obrigatórios para "Opções Incorretas" (para alimentar a múltipla escolha no App).
- [ ] **Módulo: Gestão de Usuários**
  - [ ] Desenvolver a tabela de listagem de usuários.
  - [ ] Consumir endpoint `GET /api/v1/admin/users`.
  - [ ] Mostrar o recorde de pontos de cada usuário (`max_score`).

---

## Troubleshooting: Emulador Android (Ambiente de Desenvolvimento)

Caso ocorra o erro `The Android emulator exited with code 1` ao tentar iniciar o emulador via terminal, isso geralmente indica que:
1. O emulador já está rodando (mesmo que em segundo plano e invisível).
2. Existem arquivos de *lock* (bloqueio) residuais de um travamento ou encerramento abrupto anterior.

### Passo a passo para correção e inicialização

**1. Rodar a aplicação (Se o emulador já estiver aberto e funcionando)**
Se a tela do emulador já está visível para você, ignore a mensagem de erro do terminal e inicie o app normalmente:
```bash
flutter run
```

**2. Fechar processos travados (Se o emulador não estiver visível)**
Para encerrar instâncias presas do emulador rodando em segundo plano, execute no terminal:
```bash
killall qemu-system-x86_64
```
*(Se o comando falhar, localize o processo manualmente via `ps aux | grep qemu` e use `kill -9 <PID>`).*

**3. Limpar os arquivos de Lock (Se o passo 2 não resolver)**
Delete os arquivos de "lock" na pasta do emulador travado para liberar a inicialização de uma nova instância:
```bash
rm -f ~/.android/avd/Pixel_6_API_34.avd/*.lock
```
*(Lembre-se de alterar `Pixel_6_API_34.avd` para o nome da pasta do AVD correto em seu ambiente, caso seja diferente).*

**4. Iniciar o emulador novamente**
Após garantir que os processos antigos foram mortos e os locks removidos, inicialize o emulador novamente:
```bash
flutter emulators --launch Pixel_6_API_34
```
**5. Encerrando o navegador de maneira "Limpa"**
```bash
adb emu kill
```
**6. Iniciando o Emulador com o DNS do Google (para usar o wifi)**
Iniciar o emulador usando a flag de DNS do Google: 
```bash
flutter emulators --launch Pixel_6_API_34 -dns-server 8.8.8.8
```
Após ele ligar, abra o navegador Google Chrome dentro do emulador e tente acessar um site (como google.com) para confirmar que ele tem internet.

---

## 6. Integração com GameTypes (@engineer)

O jogo possui suporte a múltiplos modos de validação de resposta, definidos pela variável **GameType**. Atualmente, as opções incluem responder utilizando tradução ou diferentes formas de Pinyin (com/sem tom, símbolos ou numérico), e todas podem ter uma versão com limite de tempo máximo estrito (Timed).

### O que o Frontend (@engineer) precisa saber:

1. **A regra do Default (PinyinWithoutTone)**
   - Caso o app faça a requisição `GET /api/v1/sessions/new?level=1` sem informar nenhum `game_type`, a API assumirá automaticamente o valor **`pinyin_without_tone`**.
   - Para a fase de MVP (onde apenas letras latinas sem acento são exigidas), o Flutter **não precisa enviar** o tipo de jogo na URL. O fluxo já funcionará perfeitamente.

2. **Como iniciar uma sessão com GameType específico**
   - Para abrir diferentes modos de jogo para o usuário, basta passar o tipo desejado como Query Parameter na criação da sessão.
   - **Exemplo:** `GET /api/v1/sessions/new?level=1&game_type=pinyin_with_numeric_tone`
   - O backend guardará essa informação (estado da sessão) no banco de dados.

3. **Submissão de Respostas**
   - Na hora de submeter a resposta em `POST /api/v1/sessions/:id/submit`, o App **não precisa** informar o `game_type` novamente.
   - O Backend checará no banco de dados qual foi a opção escolhida no início e fará a checagem correta (e.g. comparando com a coluna correspondente no banco de dados, como `PinyinWithNumericTones` ou `Translation`).

4. **Modos "Timed" (Tempo Máximo)**
   - Para qualquer GameType sufixado com `_timed` (ex: `pinyin_without_tone_timed`), o backend implementa um limite máximo rígido (ex: 60 segundos por questão).
   - O Frontend deve implementar o seu próprio timer visual, mas não gerencia a validação de tempo, pois o servidor anulará a sessão com status `403 Forbidden` se o limite máximo oficial for excedido.

> [!TIP]
> Em resumo: o Frontend só precisa se preocupar em colocar o parâmetro `game_type` na URL de Iniciar Jogo. O cálculo antifraude via hash e a correção das respostas acompanham automaticamente o tipo de jogo escolhido!

---

## 7. Guia de Preparação para a Apresentação do MVP (@engineer)

> [!IMPORTANT]
> **Atenção @engineer:** O backend Go já está oficialmente em produção no Google Cloud Run e o banco de dados Neon já contém todos os ideogramas populados. Siga este checklist rigorosamente para garantir que o App Flutter funcione perfeitamente na apresentação de hoje.

### 7.1 Configuração de Ambiente
- **URL Base da API (Produção):** Altere a configuração global do seu cliente HTTP (Dio/Http) para apontar para o backend de produção:
  `https://chinesonline-go-api-80060965106.us-east1.run.app/api/v1`
- **Ambiente de Teste:** O backend já está configurado para permitir CORS de `http://localhost:3000` (caso opte por demonstrar a versão Web). 

### 7.2 Headers Obrigatórios de Segurança
Certifique-se de que o seu Interceptor HTTP global injete **exatamente** estes dois headers em **todas** as requisições para a API em Go:
1. `Authorization: Bearer <TOKEN_JWT_FIREBASE>` (Obtido chamando `user.getIdToken()`).
2. `X-Firebase-AppCheck: <TOKEN_APP_CHECK>` (Obtido via `FirebaseAppCheck.instance.getToken()`).
  *Dica Quente:* Se for rodar no emulador (Android/iOS) na hora da apresentação em vez do app empacotado, garanta que configurou o provedor de Debug do App Check e colou o Token de Debug gerado no Firebase Console, senão o Cloud Run vai considerar seu emulador um "Bot Invasor" e responder com `401 Unauthorized`.

### 7.3 Ordem Correta do Fluxo de Autenticação
O backend validará 100% dos usuários. Se você tentar jogar sem cadastrar o perfil no Postgres, o servidor rejeitará a sessão.
1. Após o login/cadastro no SDK do Firebase, **chame obrigatoriamente** `POST /users/sync`.
2. Em seguida, chame `POST /auth/login` para registrar a entrada.
3. Somente após a API retornar `200 OK` nas duas, o Roteador do Flutter deve liberar a navegação para a Home/Quiz.

### 7.4 Testando o Game Engine (O MVP Core)
Para a demonstração brilhar:
- **Iniciar Quiz:** Acione `GET /sessions/new?level=1`. O banco em produção já está carregado com os 170 caracteres.
- **Validação Local Rápida:** Implemente uma tela que colete a resposta e use o SHA256 com o `salt` enviado. A tela de "Certo/Errado" (Verde e Vermelho) precisa brilhar sem delay de rede!
- **Submissão e Ranking:** Agrupe as respostas processadas e efetue o `POST /sessions/:id/submit`. Garanta que a pontuação validada pela API seja celebrada em uma bela "Tela de Fim de Jogo".

> [!TIP]
> Faça um ensaio completo (Logout -> Cadastro -> Login -> Jogar Lote de Nível 1 -> Ver Pontuação) antes de ir apresentar. As URLs de produção não perdoam configurações erradas de cabeçalhos. Boa sorte!

---

## 8. Spaced Repetition System (SRS) e Progressão de Nível (@engineer)

O aplicativo móvel utiliza um sistema de repetição espaçada (SRS) inspirado na ciência do aprendizado (como o Anki) para garantir a memorização efetiva a longo prazo dos flashcards (ideogramas). Além disso, a progressão do usuário é medida separadamente para cada tipo de jogo (`GameType`).

### 8.1 Separação de Progresso por Jogo
No backend, o nível e o score de um usuário **não são mais globais**. Eles são separados por `GameType`.
- Se um usuário atingir o Nível 5 no jogo de Tradução (`Translation`), ele ainda iniciará no Nível 1 no jogo de Pinyin (`PinyinWithoutTone`) até que treine e pontue nesse modo específico.
- A API `/sessions/new` e `/sessions/:id/submit` agora retornam no JSON os campos `"current_level"`, `"max_score"` e `"leveled_up"` referentes **exclusivamente** ao modo de jogo atual jogado na sessão. O seu aplicativo deve exibir o nível e a pontuação baseados na resposta do servidor.

### 8.2 A Regra Matemática de Subida de Nível (Dinâmica e Server-side)
Para subir de nível, não basta o jogador responder os ideogramas apenas uma vez. A ciência pedagógica aponta que o usuário deve ter contato com um card (e acertar) aproximadamente **5 vezes** para fixá-lo na memória de longo prazo.
- O backend calcula automaticamente a meta de pontos do nível com a fórmula: `Quantidade Real de Ideogramas no Banco × 5 (repetições mínimas) × Pontos Base do GameType`.
- **Ação no Frontend:** O App não precisa decorar ou recalcular as metas e pontos, pois o Backend o fará e informará o ganho real de pontos por sessão, assim como disparará o aviso na flag `"leveled_up": true` via JSON quando o jogador finalmente passar de nível.

### 8.3 Construção do Baralho (Deck Building) Client-Side

Para prover escalabilidade infinita e eliminar 99% dos custos de infraestrutura do banco de dados na nuvem, a inteligência de "Qual carta o usuário vai ver agora" (Spaced Repetition) **não** é processada pelo Backend. Isso deve acontecer 100% no aplicativo Flutter (Client-Side).

**Obrigações do Frontend (@engineer):**

1. **Stack de Persistência Local (Hive):**
   - É obrigatório o uso do pacote **Hive** (banco de dados NoSQL ultrarrápido em puro Dart) para salvar o histórico de erros e acertos.
   - O uso de SQLite (sqflite) é vetado para essa funcionalidade por ser lento para operações em memória necessárias durante o jogo. SharedPreferences é vetado por não ser ideal para coleções grandes.

2. **Estrutura de Dados do Histórico:**
   - Crie um Hive Box chamado `ideogram_stats`.
   - O objeto a ser persistido (TypeAdapter) deve ter o seguinte formato estrito:
     ```dart
     @HiveType(typeId: 1)
     class LocalIdeogramStat extends HiveObject {
       @HiveField(0)
       final int ideogramId;
       
       @HiveField(1)
       final String gameType; // ex: 'translation', para isolar o progresso
       
       @HiveField(2)
       int correctAttempts;
       
       @HiveField(3)
       int wrongAttempts;
       
       @HiveField(4)
       DateTime lastReviewed;
     }
     ```
   - Chave do Box (Key): Deve ser uma string combinando ID e GameType, ex: `"${ideogramId}_${gameType}"`.

3. **O Algoritmo Matemático de Peso (Weighted SRS Queue):**
   - Ao receber os ideogramas do backend via `GET /sessions/new`, o Flutter não deve exibi-los cegamente. O App cruzará a lista recebida com a Box do `Hive` e atribuirá uma nota de **Prioridade** para cada carta.
   - **Fórmula de Prioridade:** `Priority = (wrongAttempts * 3) - (correctAttempts)`
   - **Regras de Ordenação do Lote (Deck de 10 cartas):**
     - Ordene a lista da maior prioridade (mais erradas) para a menor.
     - Pegue as 10 primeiras para formar o lote atual.
     - **Regra de Espaçamento (Threshold):** Se a carta tiver uma Prioridade `<= -5` (ou seja, foi acertada no mínimo 5 vezes a mais do que errada), ela deve ser considerada "Memorizada" e filtrada/removida do lote, a menos que faltem cartas para completar as 10 vagas.

4. **Submissão Leve e Atualização:**
   - Durante a partida local, a cada resposta, atualize o `correctAttempts` ou `wrongAttempts` da carta no Hive *imediatamente* e salve.
   - Ao finalizar a sessão, envie as respostas cruas no `POST /submit` conforme especificado no item 3.2. O backend lidará apenas com a matemática financeira do score, não com as métricas do Hive.
