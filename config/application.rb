require File.expand_path('../boot', __FILE__)

require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'active_job/railtie'
# require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Botmetrics
  class Application < Rails::Application
    config.assets.initialize_on_precompile = false
    config.assets.enabled = true
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.active_record.schema_format = :sql

    # Use sidekiq for ActiveJob
    config.active_job.queue_adapter = :sidekiq

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # load env variables
    Dotenv.load if Rails.env.test?

    config.settings                       = ActiveSupport::OrderedOptions.new
    config.settings.pusher_api_key        = ENV['PUSHER_API_KEY']
    config.settings.pusher_secret         = ENV['PUSHER_SECRET']
    config.settings.pusher_app_id         = ENV['PUSHER_APP_ID']
    config.settings.pusher_url            = ENV['PUSHER_URL']
    config.settings.json_web_token_secret = ENV['JSON_WEB_TOKEN_SECRET']
    config.settings.rails_host            = ENV['RAILS_HOST']
    config.settings.on_premise            = ENV['ON_PREMISE']
    config.settings.letsencrypt_challenge = ENV['LETSENCRYPT_CHALLENGE']
  end
end

Settings = Botmetrics::Application.config.settings
