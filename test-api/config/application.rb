require_relative "boot"

require "rails"
require "active_record/railtie"
require "bcrypt"
Bundler.require(:default, Rails.env)

class Application < Rails::Application

end
