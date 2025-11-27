# Community App
A community management platform with a REST API, web interface, and basic sentiment analysis using AI.

### Dependencies
- Ruby [v3.3.9](https://www.ruby-lang.org/en/news/2025/07/24/ruby-3-3-9-released/)
- Rails [v7.2.2.2](https://rubygems.org/gems/rails/versions/7.2.2.2)
- PostgreSQL [v17](https://www.postgresql.org/download/)

If needed, see the [official Ruby installation documentation](https://www.ruby-lang.org/en/documentation/installation/).

## Running the Project Locally

#### 1. Install dependencies:
```sh
$ bundle install
```

#### 2. Setup database:
```sh
$ bundle exec rails db:create
$ bundle exec rails db:migrate
```

#### 3. Start the Rails server:
```sh
$ bundle exec rails s
```

#### 4. Visit in your browser:
http://localhost:3000

## Running Tests
```sh
$ bundle exec rspec
```

## Running the Linter
```sh
$ bundle exec rubocop
```

## ✅ Checklist de Entrega - Thais Assunção

### Repositório & Código
- [X] Código no GitHub (público): [URL DO REPO](https://github.com/thaisassuncao/community-app)
- [ ] README com instruções completas
- [ ] `.env.example` ou similar com variáveis de ambiente
- [ ] Linter/formatter configurado
- [ ] Código limpo e organizado

### Stack Utilizada
- [X] Backend: Ruby on Rails
- [X] Frontend: HAML + Stimulus + Turbo/Hotwire
- [X] Banco de dados: PostgreSQL
- [X] Testes: RSpec

### Deploy
- [ ] URL da aplicação: [URL]
- [ ] Seeds executados (dados de exemplo visíveis)

### Funcionalidades - API
- [ ] POST /api/v1/messages (criar mensagem + sentiment)
- [ ] POST /api/v1/reactions (com proteção de concorrência)
- [ ] GET /api/v1/communities/:id/messages/top
- [ ] GET /api/v1/analytics/suspicious_ips
- [ ] Tratamento de erros apropriado
- [ ] Validações implementadas

### Funcionalidades - Frontend
- [ ] Listagem de comunidades
- [ ] Timeline de mensagens
- [ ] Criar mensagem (sem reload)
- [ ] Reagir a mensagens (sem reload)
- [ ] Ver thread de comentários
- [ ] Responsivo (mobile + desktop)

### Testes
- [ ] Cobertura mínima de 70%
- [ ] Testes passando
- [ ] Como rodar: `bundle exec rspec`

### Documentação
- [ ] Setup local documentado
- [ ] Decisões técnicas explicadas
- [ ] Como rodar seeds
- [ ] Endpoints da API documentados
- [ ] Screenshot ou GIF da interface (opcional)

### ⏰ Entregue em: XX/XX/2025
