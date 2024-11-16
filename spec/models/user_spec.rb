require 'rails_helper'

RSpec.describe User, type: :model do
  # Tests for validations of instance variables
  describe 'validations' do
    it 'should be invalid on default construction' do
      # On default construction, the user and its instance variables should be invalid
      test_user = User.new
      expect(test_user).not_to be_valid
      expect(test_user).not_to be_valid
      expect(test_user).not_to be_valid
      expect(test_user).not_to be_valid
    end
  end
end
