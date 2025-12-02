#!/usr/bin/env ruby
# frozen_string_literal: true

require "httparty"
require "json"

# Configuration
# Always use localhost since we run inside the same container as the Rails server
API_BASE_URL = ENV.fetch("API_BASE_URL", "http://localhost:3000")
API_V1_BASE = "#{API_BASE_URL}/api/v1".freeze

# Data pools
COMMUNITY_NAMES = [
  { name: "Ruby Brasil", description: "Comunidade de desenvolvedores Ruby e Rails do Brasil" },
  { name: "JavaScript Developers",
    description: "Discussões sobre JavaScript, TypeScript, Node.js e frameworks modernos" },
  { name: "DevOps & Cloud", description: "Infraestrutura, containers, Kubernetes e cloud computing" },
  { name: "Data Science Brasil", description: "Machine Learning, IA, análise de dados e Python" },
  { name: "Mobile Development", description: "Desenvolvimento iOS, Android, React Native e Flutter" }
].freeze

USERNAMES = [
  "João Silva", "Maria Santos", "Pedro Oliveira", "Ana Costa", "Carlos Souza",
  "Juliana Lima", "Rafael Alves", "Fernanda Rocha", "Lucas Martins", "Camila Ferreira",
  "Gabriel Pereira", "Beatriz Rodrigues", "Thiago Carvalho", "Larissa Gomes", "Felipe Ribeiro",
  "Amanda Dias", "Bruno Barbosa", "Patricia Nunes", "Diego Monteiro", "Renata Freitas",
  "Rodrigo Correia", "Vanessa Araújo", "Marcelo Teixeira", "Cristina Moreira", "Eduardo Cardoso",
  "Aline Campos", "Gustavo Mendes", "Tatiana Castro", "Leonardo Pinto", "Isabela Lopes",
  "André Borges", "Mariana Ramos", "Vinicius Reis", "Carolina Batista", "Daniel Fonseca",
  "Bruna Cavalcanti", "Matheus Azevedo", "Stephanie Duarte", "Ricardo Moura", "Daniela Melo",
  "Fábio Cunha", "Raquel Santana", "Paulo Nogueira", "Luciana Viana", "Henrique Pires",
  "Natália Macedo", "Sérgio Barros", "Priscila Miranda", "Alexandre Soares", "Mônica Andrade"
].freeze

IP_ADDRESSES = [
  "192.168.1.10", "192.168.1.11", "192.168.1.12", "192.168.1.13", "192.168.1.14",
  "10.0.0.5", "10.0.0.6", "10.0.0.7", "10.0.0.8", "10.0.0.9",
  "172.16.0.20", "172.16.0.21", "172.16.0.22", "172.16.0.23", "172.16.0.24",
  "203.0.113.15", "203.0.113.16", "203.0.113.17", "203.0.113.18", "203.0.113.19"
].freeze

POSITIVE_MESSAGES = [
  "Excelente trabalho! Parabéns pela contribuição incrível!",
  "Adorei essa solução! Muito criativa e eficiente.",
  "Fantástico! Isso vai ajudar muita gente.",
  "Perfeito! Exatamente o que eu estava procurando.",
  "Maravilhoso! Obrigado por compartilhar esse conhecimento.",
  "Sensacional! Continue com esse ótimo trabalho.",
  "Incrível como você explicou isso de forma simples!",
  "Muito bom! Essa dica foi super útil.",
  "Amei a forma como você resolveu esse problema!",
  "Espetacular! Sua experiência é inspiradora."
].freeze

NEGATIVE_MESSAGES = [
  "Isso não funcionou para mim. Péssima experiência.",
  "Terrível, não recomendo essa abordagem.",
  "Horrível! Pior solução que já vi.",
  "Ruim demais, não serve para nada.",
  "Muito mal explicado, confuso e difícil de entender.",
  "Fracasso total, não consegui fazer funcionar.",
  "Decepcionante. Esperava muito mais.",
  "Problemático e cheio de bugs.",
  "Inútil. Perdi meu tempo com isso.",
  "Péssimo! Não resolve o problema."
].freeze

NEUTRAL_MESSAGES = [
  "Alguém já tentou usar essa biblioteca em produção?",
  "Qual a melhor forma de implementar autenticação hoje?",
  "Estou com dúvida sobre como fazer deploy dessa aplicação.",
  "Como funciona o cache no Rails 7?",
  "Quais são as melhores práticas para testes?",
  "Preciso de ajuda com configuração do Docker.",
  "Como posso otimizar essa query do banco de dados?",
  "Qual editor de código vocês recomendam?",
  "Estou migrando de JavaScript para TypeScript.",
  "Como implementar paginação eficiente?",
  "Alguém tem experiência com microserviços?",
  "Qual a diferença entre REST e GraphQL?",
  "Como fazer upload de arquivos grandes?",
  "Preciso processar dados em background.",
  "Como organizar a estrutura de pastas?"
].freeze

COMMENT_TEMPLATES = [
  "Concordo totalmente!",
  "Obrigado pela resposta!",
  "Isso faz sentido.",
  "Vou testar essa solução.",
  "Interessante ponto de vista.",
  "Não tinha pensado por esse lado.",
  "Valeu pela dica!",
  "Consegui resolver seguindo seu conselho.",
  "Ainda estou com dúvidas sobre isso.",
  "Poderia explicar melhor essa parte?"
].freeze

REACTION_TYPES = %w[like love insightful].freeze

class SeedAPI
  include HTTParty

  base_uri API_V1_BASE

  def initialize
    @communities = []
    @users = {}
    @messages = []
    @ip_addresses = IP_ADDRESSES.dup
  end

  def run
    puts "🌱 Iniciando seed via API..."
    puts "📍 API Base URL: #{API_BASE_URL}"
    puts ""

    check_server
    create_communities
    create_messages
    create_reactions
    display_summary
  end

  private

  def check_server
    print "🔍 Verificando se o servidor está rodando... "
    response = HTTParty.get("#{API_BASE_URL}/communities")
    if response.success?
      puts "✅"
    else
      puts "❌"
      puts "⚠️  Erro: Servidor não está respondendo. Inicie o servidor com 'make up' primeiro."
      exit 1
    end
  rescue StandardError => e
    puts "❌"
    puts "⚠️  Erro ao conectar: #{e.message}"
    puts "⚠️  Certifique-se de que o servidor está rodando com 'make up'"
    exit 1
  end

  def create_communities
    puts "📁 Criando comunidades..."

    COMMUNITY_NAMES.each do |community_data|
      response = post_community(community_data[:name], community_data[:description])
      next unless response.success?

      community = JSON.parse(response.body)["community"]
      @communities << community
      print "."
    end

    # Fetch all communities via GET to ensure we have all IDs
    response = self.class.get("/communities")
    if response.success?
      all_communities = JSON.parse(response.body)
      @communities = all_communities
    end

    puts " ✅ #{@communities.size} comunidades disponíveis"
  end

  def create_messages
    puts "💬 Criando mensagens..."

    total_messages = 1000
    main_posts_count = (total_messages * 0.7).to_i
    comments_count = total_messages - main_posts_count

    # Create main posts (70%)
    print "  📝 Posts principais: "
    main_posts_count.times do |i|
      community = @communities.sample
      username = USERNAMES.sample
      user_ip = @ip_addresses.sample
      content = random_message_content

      response = post_message(community["id"], username, user_ip, content)
      if response.success?
        message_data = JSON.parse(response.body)
        @messages << { id: message_data["id"], community_id: community["id"], is_main: true }
        # Store the real user_id from the API response
        @users[username] = message_data["user"]["id"] if message_data["user"]
        print "." if (i % 50).zero?
      else
        puts "\n⚠️  Erro ao criar mensagem: #{response.code} - #{response.body}"
      end
    end
    puts " ✅ #{main_posts_count} posts"

    # Create comments (30%)
    print "  💭 Comentários: "
    comments_count.times do |i|
      parent = @messages.select { |m| m[:is_main] }.sample
      next unless parent

      username = USERNAMES.sample
      user_ip = @ip_addresses.sample
      content = COMMENT_TEMPLATES.sample

      response = post_message(parent[:community_id], username, user_ip, content, parent[:id])
      next unless response.success?

      message_data = JSON.parse(response.body)
      @messages << { id: message_data["id"], community_id: parent[:community_id], is_main: false }
      # Store the real user_id from the API response
      @users[username] = message_data["user"]["id"] if message_data["user"]
      print "." if (i % 50).zero?
    end
    puts " ✅ #{comments_count} comentários"
  end

  def create_reactions
    puts "❤️  Criando reações..."

    # 80% of messages should have at least one reaction
    messages_with_reactions = (@messages.size * 0.8).to_i
    total_reactions = 0

    messages_to_react = @messages.sample(messages_with_reactions)

    messages_to_react.each_with_index do |message_data, i|
      # Each message gets 1-5 reactions
      reactions_count = rand(1..5)

      reactions_count.times do
        username = USERNAMES.sample
        user_id = get_or_create_user_id(username)
        next unless user_id # Skip if user hasn't been created yet

        reaction_type = REACTION_TYPES.sample

        response = post_reaction(message_data[:id], user_id, reaction_type)
        total_reactions += 1 if response.success?
      end

      print "." if (i % 50).zero?
    end

    puts " ✅ #{total_reactions} reações criadas"
  end

  def post_community(name, description)
    payload = {
      community: {
        name: name,
        description: description
      }
    }

    self.class.post("/communities", body: payload.to_json, headers: { "Content-Type" => "application/json" })
  end

  def post_message(community_id, username, user_ip, content, parent_message_id = nil)
    payload = {
      message: {
        community_id: community_id,
        username: username,
        user_ip: user_ip,
        content: content
      }
    }
    payload[:message][:parent_message_id] = parent_message_id if parent_message_id

    self.class.post("/messages", body: payload.to_json, headers: { "Content-Type" => "application/json" })
  end

  def post_reaction(message_id, user_id, reaction_type)
    payload = {
      reaction: {
        message_id: message_id,
        user_id: user_id,
        reaction_type: reaction_type
      }
    }

    self.class.post("/reactions", body: payload.to_json, headers: { "Content-Type" => "application/json" })
  end

  def random_message_content
    sentiment = rand(100)
    if sentiment < 30
      POSITIVE_MESSAGES.sample
    elsif sentiment < 50
      NEGATIVE_MESSAGES.sample
    else
      NEUTRAL_MESSAGES.sample
    end
  end

  def get_or_create_user_id(username)
    # Return the real user_id that was stored when creating messages
    # If the user hasn't been created yet, return nil
    @users[username]
  end

  def display_summary
    puts ""
    puts "=" * 60
    puts "✅ Seed concluído com sucesso!"
    puts "=" * 60
    puts ""
    puts "📊 Estatísticas:"
    puts "  • #{@communities.size} comunidades"
    puts "  • #{@users.size} usuários únicos"
    puts "  • #{@messages.size} mensagens totais"
    puts "  • #{@messages.count { |m| m[:is_main] }} posts principais (70%)"
    puts "  • #{@messages.count { |m| !m[:is_main] }} comentários (30%)"
    puts "  • #{@ip_addresses.size} IPs únicos"
    puts ""
    puts "🌐 Acesse: #{API_BASE_URL}/communities"
    puts ""
  end
end

# Run the seed
SeedAPI.new.run
