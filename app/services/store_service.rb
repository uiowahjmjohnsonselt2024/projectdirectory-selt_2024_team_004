class StoreService
  def self.fetch_prices(user)
    currency = user.default_currency || 'USD'
    exchange_rates = fetch_exchange_rates

    # Base USD prices
    usd_prices = {
      sea_shard: 0.75,
      pile_of_shards: 7.00,
      hat_of_shards: 30.00,
      chest_of_shards: 50.00
    }

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
