Rails.application.configure do

  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.read_encrypted_secrets = true

  config.public_file_server.enabled = false
  config.log_level = :debug

  config.i18n.fallbacks = true

  config.log_formatter = ::Logger::Formatter.new
end
