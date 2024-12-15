require 'rails_helper'
require 'webmock/rspec'

RSpec.describe OpenExchangeService do
  describe '.fetch_currencies' do
    it 'returns a hash of currency codes and names' do
      stub_request(:get, "https://openexchangerates.org/api/currencies.json?app_id=#{ENV['OPEN_EXCHANGE_APP_ID']}")
        .to_return(status: 200, body: '{"USD": "United States Dollar", "EUR": "Euro"}', headers: {})

      result = OpenExchangeService.fetch_currencies
      expect(result).to eq({ 'USD' => 'United States Dollar', 'EUR' => 'Euro' })
    end

    it 'handles errors gracefully' do
      stub_request(:get, "https://openexchangerates.org/api/currencies.json?app_id=#{ENV['OPEN_EXCHANGE_APP_ID']}")
        .to_raise(StandardError.new('Network error'))

      result = OpenExchangeService.fetch_currencies
      expect(result).to eq({})
    end
  end
end
