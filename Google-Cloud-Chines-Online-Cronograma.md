# Cronograma Geral do Projeto ChinesOnline (MVP)
- **Fase 1:** Infraestrutura & Fundação (Semana 1)
- **Fase 2:** Backend API - CRUD e Auth (Semanas 2-3)
- **Fase 3:** Frontend Administrativo (Semana 4)
- **Fase 4:** Backend API - Game Engine (Semana 5)
- **Fase 5:** O Aplicativo Flutter - MVP (Semanas 6-8)
- **Fase 6:** Anti-Cheat & Deploy (Semanas 9-10)

---

# Tarefas Detalhadas: Google Cloud Platform (GCP)

## Fase 1: Fundação do GCP
- [ ] **Configuração do Projeto e IAM**
  - [ ] Criar um novo projeto no Google Cloud (ex: `chinesonline-prod`).
  - [ ] Habilitar o faturamento (Billing).
  - [ ] Criar Roles/IAM para você gerenciar os recursos.

## Fase 6: Deploy & Continuous Integration
- [ ] **Google Artifact Registry**
  - [ ] Habilitar a API do Artifact Registry.
  - [ ] Criar um repositório Docker na nuvem para armazenar as imagens compiladas da sua API em Go.
- [ ] **Google Cloud Run (Servidor Serverless do Backend Go)**
  - [ ] Habilitar a API do Cloud Run.
  - [ ] Configurar o serviço Cloud Run para permitir acesso não-autenticado (A sua API em Go vai cuidar da própria autenticação internamente usando o middleware do Firebase).
  - [ ] Fazer injeção de variáveis de ambiente sensíveis via Secrets Manager ou diretamente no serviço (URL do Banco de Dados Neon, Firebase Admin SDK Key).
  - [ ] Configurar o Autoscaling do Cloud Run (Mínimo de instâncias = 0 para não pagar nada na madrugada, Máximo = 10 para segurar pico).
- [ ] **CI/CD Automatizado (GitHub Actions)**
  - [ ] Criar um script `deploy.yml` no GitHub Actions do repositório Go.
  - [ ] Toda vez que der "Push" na branch `main`, o GitHub Actions:
    1. Faz login no Google Cloud via Workload Identity Federation (ou JSON key).
    2. Compila a imagem Docker do Go.
    3. Dá Push da imagem para o Artifact Registry.
    4. Atualiza o serviço no Cloud Run com a nova imagem.
- [ ] **Domínio e Certificado SSL**
  - [ ] Mapear um domínio customizado (ex: `api.chinesonline.com`) para o serviço do Cloud Run.
  - [ ] O Google Cloud provisionará o certificado SSL automaticamente (necessário para o SSL Pinning do Flutter funcionar).
