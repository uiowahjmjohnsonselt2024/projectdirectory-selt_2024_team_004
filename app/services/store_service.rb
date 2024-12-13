class StoreService
  def self.fetch_prices(currency)
    exchange_rates = fetch_exchange_rates

    # Base USD prices
    usd_prices = {
      sea_shard_1: 0.75,
      pile_of_shards_10: 7.50,
      hat_of_shards_50: 30.00,
      chest_of_shards_100: 50.00
    }
    puts "FETCH_PRICES DATA: #{exchange_rates}, #{usd_prices}, #{currency}"

    # Convert prices to the user's selected currency
    new_prices = usd_prices.transform_values { |usd_price| (usd_price * exchange_rates[currency]).round(2).to_s }
    new_prices.transform_values! { |value| '%.2f' % value.to_f }
  end

  def self.fetch_exchange_rates
    cached_rates = Rails.cache.fetch('exchange_rates', expires_in: 12.hours) do
      OpenExchangeService.fetch_exchange_rates
    end
    cached_rates['rates']
  rescue StandardError => e
    Rails.logger.error "Exception fetching exchange rates: #{e.message}"
    { 'USD' => 1.0 }
  end
end
