source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.10'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.6.1'
gem 'ffi', '= 1.16.3'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5'
gem 'uglifier', '>= 2.7.1'
gem 'jquery-rails'

gem 'ruby-openai'

gem 'dotenv-rails', groups: [:development, :test]

# Bcrypt can help us hash and store passwords securely
gem 'bcrypt', '~> 3.1.7'
# Rubocop can help us maintain ruby styling and best practices
gem 'rubocop-rails', require: false
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
gem 'redis-rails'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'httparty'
gem "ruby-openai"

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'database_cleaner'
  gem 'cucumber-rails', '~> 1.8.0', require: false
  gem 'rspec-rails', '~> 4.0.0'
  gem 'dotenv-rails'

  gem 'pry'
  gem 'pry-byebug', '~> 3.9.0'

  gem 'sqlite3'

  # Letter_opener can let us view emails without having to send them
  gem 'letter_opener'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  gem 'webmock'

  gem 'simplecov', require: false
  gem 'rails-controller-testing'
end

group :production do
  gem 'pg', '~> 0.2'
  gem 'rails_12factor'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]