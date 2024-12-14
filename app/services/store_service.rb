class StoreService
  PRICES = {
    sea_shard_1: 0.75,
    pile_of_shards_10: 7.50,
    hat_of_shards_50: 30.00,
    chest_of_shards_100: 50.00
  }

  def self.fetch_prices(currency = 'USD')
    return PRICES if currency == 'USD'

    begin
      app_id = ENV['OPEN_EXCHANGE_APP_ID']
      response = HTTParty.get("https://openexchangerates.org/api/latest.json?app_id=#{app_id}")
      
      if response.success? && response['rates'] && response['rates'][currency]
        rate = response['rates'][currency]
        PRICES.transform_values { |price| (price * rate).round(2) }
      else
        # If API call fails, return USD prices as fallback
        PRICES
      end
    rescue => e
      Rails.logger.error "Currency conversion error: #{e.message}"
      # Return USD prices as fallback
      PRICES
    end
  end
end
