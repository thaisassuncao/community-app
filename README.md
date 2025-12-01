# Community App
A community management platform with a REST API, web interface, and basic sentiment analysis using AI.

### Dependencies
- Ruby [v3.3.9](https://www.ruby-lang.org/en/news/2025/07/24/ruby-3-3-9-released/)
- Rails [v7.2.2.2](https://rubygems.org/gems/rails/versions/7.2.2.2)
- PostgreSQL [v17](https://www.postgresql.org/download/)
- Docker Engine (CLI) [v27+](https://docs.docker.com/engine/install/) (optional, recommended for testing)

If needed, see the [official Ruby installation documentation](https://www.ruby-lang.org/en/documentation/installation/).

## Running with Docker (Recommended)

Docker allows you to run the project and tests **without installing PostgreSQL locally**.

#### 1. Build the images:
```sh
$ make build
```

#### 2. Setup test database:
```sh
$ make test-setup
```

#### 3. Run tests:
```sh
$ make test
```

#### 4. Run linter:
```sh
$ make lint
```

#### 5. Start the application (development):
```sh
$ make up
```

Visit: http://localhost:3000

#### Other useful commands:
```sh
$ make help          # Show all available commands
$ make down          # Stop containers
$ make shell         # Open shell in container
$ make logs          # View application logs
```

## Running Locally (Without Docker)

Requires PostgreSQL installed and running locally.

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
- [X] `.env.example` ou similar com variáveis de ambiente
- [X] Linter/formatter configurado
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
- [X] POST /api/v1/messages (criar mensagem + sentiment)
- [X] POST /api/v1/reactions (com proteção de concorrência)
- [X] GET /api/v1/communities/:id/messages/top
- [X] GET /api/v1/analytics/suspicious_ips
- [X] Tratamento de erros apropriado
- [X] Validações implementadas

### Funcionalidades - Frontend
- [ ] Listagem de comunidades
- [ ] Timeline de mensagens
- [ ] Criar mensagem (sem reload)
- [ ] Reagir a mensagens (sem reload)
- [ ] Ver thread de comentários
- [ ] Responsivo (mobile + desktop)

### Testes
- [ ] Cobertura mínima de 70%
- [X] Testes passando
- [X] Como rodar: `bundle exec rspec` ou `make test`

### Documentação
- [X] Setup local documentado
- [ ] Decisões técnicas explicadas
- [ ] Como rodar seeds
- [ ] Endpoints da API documentados
- [ ] Screenshot ou GIF da interface (opcional)

### ⏰ Entregue em: XX/XX/2025
