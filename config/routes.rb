require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: :registrations, invitations: :invitations }

  resources :settings, only: [:new, :create]

  resources :bots, only: [:index, :show, :new, :create, :edit, :update] do
    resources :events, only: [:create]
    resources :dashboards, only: [:index, :show, :new, :create]

    get :verifying_webhook
    get :webhook_events, on: :member

    resources :instances, only: [:new, :create, :show, :edit, :update], controller: :bot_instances do
      member do
        get :setting_up
      end
    end

    resources :retention, only: [:index]

    resources :notifications, except: [:new, :create, :edit, :update]
    resources :new_notification, only: [:create] do
      collection do
        get :step_1
        get :step_2
        get :step_3
      end
    end
    resources :edit_notification, only: [:update] do
      member do
        get :step_1
        get :step_2
        get :step_3
      end
    end

    resources :messages, only: [:create]

    resources :insights, only: [:index]
  end

  resources :users, only: [:show, :update] do
    member do
      patch :regenerate_api_key
    end
  end

  root 'static#index'

  get '/.well-known/acme-challenge/:id' => 'static#letsencrypt', protocol: 'http'
  get '/privacy' => 'static#privacy'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end

  mount Sidekiq::Web, at: "/sidekiq"

  unless Rails.env.production?
    mount SlackApiMocks, at: "/slack_api_mocks"
    mount FacebookApiMocks, at: "/facebook_api_mocks"
  end
end
