class StoreService
  PRICES = {
    sea_shard_1: 0.75,
    pile_of_shards_10: 7.50,
    hat_of_shards_50: 30.00,
    chest_of_shards_100: 50.00
  }

  def self.fetch_prices(currency)
    puts "\n=== Starting Price Conversion ==="
    puts "Original USD prices: #{PRICES}"
    puts "Target currency: #{currency}"
    
    return PRICES if currency.nil? || currency == 'USD'

    begin
      rates_data = OpenExchangeService.fetch_exchange_rates
      puts "Received exchange rates data: #{rates_data.inspect}"
      
      if rates_data && rates_data['rates'] && rates_data['rates'][currency]
        rate = rates_data['rates'][currency].to_f
        puts "\nExchange rate found: 1 USD = #{rate} #{currency}"
        
        converted_prices = {}
        PRICES.each do |key, usd_price|
          converted_price = (usd_price * rate).round(2)
          puts "Converting #{key}: #{usd_price} USD -> #{converted_price} #{currency}"
          converted_prices[key] = converted_price
        end
        
        puts "\nFinal converted prices: #{converted_prices}"
        puts "=== Conversion Complete ===\n"
        converted_prices
      else
        Rails.logger.error "Failed to get exchange rate for #{currency}"
        puts "Failed to get rate - returning USD prices"
        PRICES
      end
    rescue => e
      Rails.logger.error "Currency conversion error: #{e.message}"
      puts "Error during conversion: #{e.message}"
      PRICES
    end
  end
end