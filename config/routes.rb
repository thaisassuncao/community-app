# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :messages, only: [:create]
      resources :reactions, only: [:create]

      resources :communities, only: [] do
        member do
          get "messages/top", to: "communities#top_messages"
        end
      end

      namespace :analytics do
        get :suspicious_ips
      end
    end
  end
end
