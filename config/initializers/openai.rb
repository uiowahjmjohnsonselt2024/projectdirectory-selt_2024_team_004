require 'openai'

OpenAI.configure do |config|
  config.access_token = ENV['OPENAI_API_KEY'] # Store your API key securely in .env
end
