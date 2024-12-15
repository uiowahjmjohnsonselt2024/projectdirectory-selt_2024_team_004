class StoreService
  PRICES = {
    sea_shard_1: 0.75,
    pile_of_shards_10: 7.50,
    hat_of_shards_50: 30.00,
    chest_of_shards_100: 50.00
  }

  def self.fetch_prices(currency)
    return PRICES if currency.nil? || currency == 'USD'

    begin
      rates_data = OpenExchangeService.fetch_exchange_rates
      
      if rates_data && rates_data['rates'] && rates_data['rates'][currency]
        rate = rates_data['rates'][currency].to_f
        
        converted_prices = {}
        PRICES.each do |key, usd_price|
          converted_price = (usd_price * rate).round(2)
          converted_prices[key] = converted_price
        end
        converted_prices
      else
        Rails.logger.error "Failed to get exchange rate for #{currency}"
        PRICES
      end
    rescue => e
      Rails.logger.error "Currency conversion error: #{e.message}"
      PRICES
    end
  end
end