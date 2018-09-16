source 'https://rubygems.org'

ruby '2.1.6'

# Rails
gem 'active_model_serializers', '~> 0.9.3'
gem 'rails', '4.2.1'

# Roles / Authorization
gem 'rolify', '~> 4.1.1'

# Web server
gem 'puma', '~> 2.11.3'
gem 'rack-cors', :require => 'rack/cors'

# Settings
gem 'rails_config', '~> 0.4.2'
gem 'virtus'
gem 'virtus_convert'

# Database Gems
gem 'pg', '~> 0.17.1'

# Email
gem 'pony', '~> 1.11'

# Encryption gem
gem "bcrypt", '~> 3.1.10'

# API version
gem 'versionist'

# Asset Management
gem 'slim-rails', '~> 3.0.1'
gem 'coffee-rails', '~> 4.0.0'
gem 'sass-rails', '~> 5.0.3'
gem 'uglifier', '>= 1.3.0'

# File uploading
gem "paperclip", "~> 4.2"

# AWS
gem 'aws-sdk', '< 2' # because Paperclip sucks

# Parser Tools
gem 'nokogiri', '~> 1.6.6.2'
gem 'docx-html'
gem 'redcarpet'

# Javascript
gem 'therubyracer',  '~> 0.12.2', platforms: :ruby
gem 'react-rails', '~> 1.0.0'
gem 'jquery-rails', '~> 3.1.2'
gem 'jquery-ui-rails', '~> 5.0.3'
gem 'underscore-rails', '~> 1.8.2'
gem 'browserify-rails', '~> 0.7'

# Excel Output
gem 'axlsx_rails'

# Stylesheets
gem 'neat', '~> 1.7.2'
gem 'bourbon', '~> 4.0'
gem 'normalize-rails', :git => 'https://github.com/markmcconachie/normalize-rails.git'

# Other
group :edge, :production do
  gem 'newrelic_rpm' # perf analysis
  gem 'rails_12factor' # Heroku stuff
  gem 'rollbar'
end

# Testing Gems
group :development, :test do
  gem 'autotest-rails'
  gem 'byebug'
  gem 'pry-awesome_print'
  gem 'capistrano',  '~> 3.4.0'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano3-puma',   require: false
  gem 'capistrano-rvm',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-npm',     require: false
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'annotate'
  gem 'letter_opener'
end

group :test do
  gem 'simplecov', require: false
  gem 'database_cleaner'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'poltergeist'
end

# Cool console output
gem 'awesome_print'
gem 'coderay'
