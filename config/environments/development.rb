Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Set true if you want to send emails from development.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_dispatch.tld_length = 0

  host = ENV.fetch("HOST_URL", 'localhost')
  port = ENV.fetch("ROUTE_PORT", 3000)

  routes.default_url_options = {
      host: host,
      port: port
  }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.asset_host = "http://#{host}:#{port}"
  config.action_mailer.default_url_options = {
      host: host,
      port: port
  }

  smtp_address = ENV.fetch('SMTP_ADDRESS', 'localhost')
  smtp_port = ENV.fetch('SMTP_PORT', 1025)
  smtp_domain = ENV.fetch('SMTP_DOMAIN', 'therelease.ninja')
  smtp_username = ENV.fetch('SMTP_USERNAME', '')
  smtp_password = ENV.fetch('SMTP_PASSWORD', '')

  config.action_mailer.smtp_settings = {
    address:              smtp_address,
    port:                 smtp_port,
    domain:               smtp_domain,
    user_name:            smtp_username,
    password:             smtp_password,
    authentication:       'login',
    enable_starttls_auto: true
  }
end
