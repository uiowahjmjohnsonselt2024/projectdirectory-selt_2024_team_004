require 'rails_helper'

RSpec.describe FakePaymentService do
  describe '.charge' do
    let(:valid_card) do
      {
        card_number: '4111111111111111',
        expiration_date: '12/25',
        cvv: '123'
      }
    end

    let(:invalid_card_number) { valid_card.merge(card_number: '5111111111111111') }
    let(:invalid_expiration_date) { valid_card.merge(expiration_date: '13/25') }
    let(:invalid_cvv) { valid_card.merge(cvv: '12') }

    context 'when the card is valid' do
      it 'returns a success response with a transaction ID' do
        response = FakePaymentService.charge(100, valid_card)
        expect(response[:status]).to eq('Success')
        expect(response[:transaction_id]).to match(/\Atxn_[a-f0-9]{16}\z/)
      end
    end

    context 'when the card number is invalid' do
      it 'returns a failure response with an invalid card number error' do
        response = FakePaymentService.charge(100, invalid_card_number)
        expect(response[:status]).to eq('Failure')
        expect(response[:error]).to eq('Invalid credit card number')
      end
    end

    context 'when the expiration date is invalid' do
      it 'returns a failure response with an invalid expiration date error' do
        response = FakePaymentService.charge(100, invalid_expiration_date)
        expect(response[:status]).to eq('Failure')
        expect(response[:error]).to eq('Invalid expiration date')
      end
    end

    context 'when the CVV is invalid' do
      it 'returns a failure response with an invalid CVV error' do
        response = FakePaymentService.charge(100, invalid_cvv)
        expect(response[:status]).to eq('Failure')
        expect(response[:error]).to eq('Invalid cvv')
      end
    end
  end
end
