require 'net/http'
require 'json'

class OpenExchangeService
  BASE_URL = 'https://openexchangerates.org/api'.freeze
  APP_ID = ENV['OPEN_EXCHANGE_APP_ID'] # Store your API key securely in the environment

  def self.fetch_currencies
    url = URI("#{BASE_URL}/currencies.json?app_id=#{APP_ID}")
    response = Net::HTTP.get(url)
    JSON.parse(response) # Returns a hash of currency codes and names
  rescue StandardError => e
    Rails.logger.error("Error fetching currencies: #{e.message}")
    {}
  end
end
