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

**With Docker:**
```sh
$ make test
```

**Locally:**
```sh
$ bundle exec rspec
```

## Running the Linter

**With Docker:**
```sh
$ make lint
```

**Locally:**
```sh
$ bundle exec rubocop
```

## Seeding the Database

The project provides two methods for populating the database.

#### Prerequisites
- Application must be running (via Docker or locally)
- Database created and migrated

### Simple Seed

Uses Rails standard seeding with direct database access.

Creates:
- **3 communities** (Ruby on Rails, JavaScript, General Discussion)
- **5 users** (user1 through user5)
- **~30 messages** with random sentiment
- **Random reactions** on messages

**With Docker:**
```sh
$ make db-seed
```

**Locally:**
```sh
$ bundle exec rails db:seed
```

### API-Based Seed

Populates the database through HTTP calls to the API endpoints, testing the API in the process.

Creates:
- **5 communities** (Ruby Brasil, JavaScript Developers, DevOps & Cloud, Data Science Brasil, Mobile Development)
- **50 unique users** with Brazilian names
- **1000 messages** total:
  - 70% are main posts
  - 30% are comments/replies
- **20 different unique IPs**
- **80% of messages** have at least one reaction (👍 like, ❤️ love, 💡 insightful)
- **Automatic sentiment analysis** on all messages (positive, negative, or neutral)

#### With Docker (Recommended)

1. Make sure the application is running:
```sh
$ make up
```

2. In another terminal, run the seed script:
```sh
$ make seed
```

#### Locally (Without Docker)

1. Make sure the application is running:
```sh
$ bundle exec rails s
```

2. In another terminal, run the script:
```sh
$ bundle exec rails runner scripts/seed_via_api.rb
```

### Resetting the Database

To clean the database and start fresh:

**With Docker:**
```sh
$ make db-reset
```

**Locally:**
```sh
$ bundle exec rails db:reset
```

## API Documentation

The application has complete API documentation using Swagger/OpenAPI 3.0.

### View Interactive Documentation

After starting the application, access the interactive documentation at:

**http://localhost:3000/api-docs**

The Swagger UI interface allows you to:
- View all available endpoints
- See details of parameters, request bodies and responses
- Test endpoints directly in the browser
- View request and response examples

### Documented Endpoints

API V1 contains the following endpoints:

#### Communities
- `GET /api/v1/communities` - List all communities
- `POST /api/v1/communities` - Create new community
- `GET /api/v1/communities/{id}/messages/top` - Top messages by engagement

#### Messages
- `POST /api/v1/messages` - Create new message (with automatic sentiment analysis)

#### Reactions
- `POST /api/v1/reactions` - Add reaction to a message

#### Analytics
- `GET /api/v1/analytics/suspicious_ips` - Identify suspicious IPs (used by multiple users)

### Generate/Update Documentation

To regenerate Swagger documentation after modifying endpoints:

**With Docker:**
```sh
$ make api-docs
```

**Locally:**
```sh
$ bundle exec rake rswag:specs:swaggerize
```

This will:
1. Run integration specs in `spec/integration/api/v1/`
2. Generate the `swagger/v1/swagger.yaml` file with OpenAPI documentation
3. Documentation will be automatically available at `/api-docs`

## ✅ Checklist de Entrega - Thais Assunção

### Repositório & Código
- [X] Código no GitHub (público): [URL DO REPO](https://github.com/thaisassuncao/community-app)
- [X] README com instruções completas
- [X] `.env.example` ou similar com variáveis de ambiente
- [X] Linter/formatter configurado
- [X] Código limpo e organizado

### Stack Utilizada
- [X] Backend: Ruby on Rails
- [X] Frontend: HAML + Stimulus + Turbo/Hotwire
- [X] Banco de dados: PostgreSQL
- [X] Testes: RSpec

### Deploy (Não foi feito)
- [ ] URL da aplicação: [URL]
- [ ] Seeds executados (dados de exemplo visíveis) 

Não foi feito devido a tempo hábil.

### Funcionalidades - API
- [X] POST /api/v1/messages (criar mensagem + sentiment)
- [X] POST /api/v1/reactions (com proteção de concorrência)
- [X] GET /api/v1/communities/:id/messages/top
- [X] GET /api/v1/analytics/suspicious_ips
- [X] Tratamento de erros apropriado
- [X] Validações implementadas

### Funcionalidades - Frontend
- [X] Listagem de comunidades
- [X] Timeline de mensagens
- [X] Criar mensagem (sem reload)
- [X] Reagir a mensagens (sem reload)
- [X] Ver thread de comentários
- [X] Responsivo (mobile + desktop)

### Testes
- [X] Cobertura mínima de 70%
- [X] Testes passando
- [X] Como rodar: `bundle exec rspec` ou `make test`

### Documentação
- [X] Setup local documentado
- [X] Decisões técnicas explicadas
- [X] Como rodar seeds
- [X] Endpoints da API documentados: `rswag`, `/api-docs`
- [ ] Screenshot ou GIF da interface (opcional)

### ⏰ Entregue em: 01/12/2025
