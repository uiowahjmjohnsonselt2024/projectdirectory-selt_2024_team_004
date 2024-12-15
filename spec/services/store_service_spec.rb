require 'rails_helper'

RSpec.describe StoreService do
  describe '.fetch_prices' do
    let(:usd_prices) do
      {
        sea_shard_1: 0.75,
        pile_of_shards_10: 7.50,
        hat_of_shards_50: 30.00,
        chest_of_shards_100: 50.00
      }
    end

    context 'when currency is USD' do
      it 'returns the original USD prices' do
        prices = StoreService.fetch_prices('USD')
        expect(prices).to eq(usd_prices)
      end
    end

    context 'when currency is nil' do
      it 'returns the original USD prices' do
        prices = StoreService.fetch_prices(nil)
        expect(prices).to eq(usd_prices)
      end
    end

    context 'when currency conversion is successful' do
      let(:exchange_rates) do
        {
          'rates' => {
            'EUR' => 0.9
          }
        }
      end

      before do
        allow(OpenExchangeService).to receive(:fetch_exchange_rates).and_return(exchange_rates)
      end

      it 'returns prices converted to the given currency' do
        prices = StoreService.fetch_prices('EUR')
        expected_prices = {
          sea_shard_1: 0.68, # 0.75 * 0.9
          pile_of_shards_10: 6.75, # 7.50 * 0.9
          hat_of_shards_50: 27.0, # 30.00 * 0.9
          chest_of_shards_100: 45.0 # 50.00 * 0.9
        }
        expect(prices).to eq(expected_prices)
      end
    end

    context 'when currency conversion fails' do
      before do
        allow(OpenExchangeService).to receive(:fetch_exchange_rates).and_return(nil)
        allow(Rails.logger).to receive(:error) # Suppress logging in test output
      end

      it 'logs an error and returns the original USD prices' do
        expect(Rails.logger).to receive(:error).with(/Failed to get exchange rate for EUR/)
        prices = StoreService.fetch_prices('EUR')
        expect(prices).to eq(usd_prices)
      end
    end

    context 'when an exception occurs during currency conversion' do
      before do
        allow(OpenExchangeService).to receive(:fetch_exchange_rates).and_raise(StandardError.new('Unexpected error'))
        allow(Rails.logger).to receive(:error) # Suppress logging in test output
      end

      it 'logs the error and returns the original USD prices' do
        expect(Rails.logger).to receive(:error).with(/Currency conversion error: Unexpected error/)
        prices = StoreService.fetch_prices('EUR')
        expect(prices).to eq(usd_prices)
      end
    end

    context 'when exchange rates are missing the requested currency' do
      let(:exchange_rates) do
        {
          'rates' => {
            'GBP' => 0.8
          }
        }
      end

      before do
        allow(OpenExchangeService).to receive(:fetch_exchange_rates).and_return(exchange_rates)
        allow(Rails.logger).to receive(:error) # Suppress logging in test output
      end

      it 'logs an error and returns the original USD prices' do
        expect(Rails.logger).to receive(:error).with(/Failed to get exchange rate for EUR/)
        prices = StoreService.fetch_prices('EUR')
        expect(prices).to eq(usd_prices)
      end
    end
  end
end
