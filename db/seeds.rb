# frozen_string_literal: true

# Simple seed file for quick database population
# For more comprehensive seeding via API, use: rails runner scripts/seed_via_api.rb

Rails.logger.debug "Cleaning database..."
Message.destroy_all
Community.destroy_all
User.destroy_all

Rails.logger.debug "Creating users..."
users = []
5.times do |i|
  users << User.create!(username: "user#{i + 1}")
end

Rails.logger.debug "Creating communities..."
communities = [
  Community.create!(
    name: "Ruby on Rails",
    description: "Discuta tudo relacionado ao Ruby on Rails framework!"
  ),
  Community.create!(
    name: "JavaScript",
    description: "Compartilhe suas dicas JavaScript!"
  ),
  Community.create!(
    name: "Conversa Geral",
    description: "Converse sobre qualquer coisa relacionada a tech!"
  )
]

Rails.logger.debug "Creating messages..."
communities.each do |community|
  10.times do
    message = Message.create!(
      user: users.sample,
      community: community,
      content: [
        "Este framework é ótimo e excelente!",
        "Isso é ruim e péssimo",
        "Hoje vou almoçar macarrão",
        "Adorei esta comunidade, muito legal!",
        "Não gostei muito, está chato",
        "Projeto interessante e bem estruturado"
      ].sample,
      user_ip: "192.168.1.#{rand(1..255)}"
    )

    # Add some replies
    rand(0..3).times do
      Message.create!(
        user: users.sample,
        community: community,
        parent_message: message,
        content: [
          "Concordo totalmente!",
          "Não concordo com isso",
          "Interessante ponto de vista",
          "Excelente observação!"
        ].sample,
        user_ip: "192.168.1.#{rand(1..255)}"
      )
    end

    # Add some reactions
    rand(1..5).times do
      Reaction.create(
        message: message,
        user: users.sample,
        reaction_type: %w[like love insightful].sample
      )
    rescue ActiveRecord::RecordInvalid
      # Skip duplicate reactions
    end
  end
end

Rails.logger.debug "Seed completed!"
Rails.logger.debug { "Created #{User.count} users" }
Rails.logger.debug { "Created #{Community.count} communities" }
Rails.logger.debug { "Created #{Message.count} messages" }
Rails.logger.debug { "Created #{Reaction.count} reactions" }
