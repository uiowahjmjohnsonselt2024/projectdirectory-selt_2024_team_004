require 'rails_helper'

RSpec.describe User, type: :model do
  # Tests for validations of instance variables
  describe 'validations' do
    it 'should be invalid on default construction' do
      # On default construction, the user and its instance variables should be invalid
      test_user = User.new
      expect(test_user).not_to be_valid
      expect(test_user.name).to eq(nil)
      expect(test_user.email).to eq(nil)
      expect(test_user.password).to eq(nil)
    end

    # Create a valid user before each of the tests within the context block
    context 'with an initially valid user' do
      let(:valid_user) do
        user = User.new
        user.name = 'John Doe'
        user.email = 'John.Doe@example.com'
        user.password = 'StrongPassword#123'
        user.password_confirmation = 'StrongPassword#123'
        user
      end
      it 'should be valid with valid instance variables' do
        expect(valid_user).to be_valid
      end
      it 'should be invalid if name is too long' do
        valid_user.name = "Hello this is going to be a very long string, it needs to be at least 50 characters
                        long to exceed the maximum length and make the instance variable name invalid."
        expect(valid_user).not_to be_valid
      end
      it 'should be invalid if email does not match regex' do
        valid_user.email = 'not a valid email'
        expect(valid_user).not_to be_valid
      end
      it 'should be invalid if password is too short' do
        valid_user.password = 'a'
        expect(valid_user).not_to be_valid
      end
      it 'should be invalid is password confirmation does not match' do
        valid_user.password_confirmation = 'differentPassword'
        expect(valid_user).not_to be_valid
      end

      # Test before_save to ensure email is downcase and session token is created
      context 'when the user is saved' do
        before do
          valid_user.save
        end

        it 'should downcase the email before saving' do
          expect(valid_user.email).to eq('john.doe@example.com')
        end
        it 'should create a session token before saving' do
          expect(valid_user.session_token).not_to be_nil
        end
      end
    end
  end
end
