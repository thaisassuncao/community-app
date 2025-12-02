# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs" if defined?(Rswag::Ui)
  mount Rswag::Api::Engine => "/api-docs" if defined?(Rswag::Api)

  root "communities#index"

  resources :communities, only: %i[index show]
  resources :messages, only: %i[show create] do
    resources :reactions, only: [:create]
  end

  namespace :api do
    namespace :v1 do
      resources :messages, only: [:create]
      resources :reactions, only: [:create]

      resources :communities, only: %i[index create] do
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
