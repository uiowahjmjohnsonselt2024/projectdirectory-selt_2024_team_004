class FakePaymentService
  def self.charge(price, credit_card)
    # Would actually charge to card using price after validating success
    valid_card?(credit_card)
  end

  private

  # Only accepts Visa cards (begins with 4)
  def self.valid_card?(credit_card)
    valid_number = credit_card[:card_number].to_s.match?(/\A4[0-9]{12}(?:[0-9]{3})?\z/)
    valid_date = credit_card[:expiration_date].to_s.match?(/\A(0[1-9]|1[0-2])\/\d{2}\z/)
    valid_cvv = credit_card[:cvv].to_s.match?(/\A\d{3}\z/)

    return { status: "Failure", error: "Invalid credit card number" } unless valid_number
    return { status: "Failure", error: "Invalid expiration date" } unless valid_date
    return { status: "Failure", error: "Invalid cvv" } unless valid_cvv
    return { status: "Success", transaction_id: "txn_#{SecureRandom.hex(8)}" }
  end
end