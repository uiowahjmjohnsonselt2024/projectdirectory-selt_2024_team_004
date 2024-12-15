require 'spec_helper'
require 'rails_helper'
require 'action_controller_workaround'

describe SessionsController, type: :controller do
  let(:user) do
    User.create!(
      name: 'Test User',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  describe 'POST #create' do
    context 'with missing email or password' do
      it 'renders new with an error for missing email' do
        post :create, params: { email: '', password: 'password' }

        expect(session[:user_id]).to be_nil
        expect(flash.now[:alert]).to eq('Invalid email/password combination')
        expect(response).to render_template(:new)
      end

      it 'renders new with an error for missing password' do
        post :create, params: { email: user.email, password: '' }

        expect(session[:user_id]).to be_nil
        expect(flash.now[:alert]).to eq('Invalid email/password combination')
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST #recovery_code' do
    context 'with blank email' do
      it 'renders the recovery template with an error' do
        post :recovery_code, params: { email: '' }

        expect(flash.now[:alert]).to eq('An account does not exist under that email')
        expect(response).to render_template(:recovery)
      end
    end

    context 'with invalid email format' do
      it 'renders the recovery template with an error' do
        post :recovery_code, params: { email: 'invalid_email' }

        expect(flash.now[:alert]).to eq('An account does not exist under that email')
        expect(response).to render_template(:recovery)
      end
    end
  end

  describe 'POST #verify' do
    context 'when user is not found' do
      it 'renders code template with an error' do
        post :verify, params: {
          email: 'nonexistent@example.com',
          code: 'validcode',
          recovery_code: 'validcode',
          password: 'newpassword',
          password_confirm: 'newpassword'
        }

        expect(flash.now[:alert]).to eq('User not found')
        expect(response).to render_template(:code)
      end
    end

    context 'when passwords do not match' do
      it 'renders code template with an error' do
        recovery_code = SecureRandom.hex(4)
        post :verify, params: {
          email: user.email,
          code: recovery_code,
          recovery_code: recovery_code,
          password: 'newpassword',
          password_confirm: 'differentpassword'
        }

        expect(flash.now[:alert]).to eq('Invalid recovery code or passwords do not match.')
        expect(response).to render_template(:code)
      end
    end

    context 'with valid recovery but invalid user' do
      it 'renders code template with an error' do
        recovery_code = SecureRandom.hex(4)
        post :verify, params: {
          email: 'invalid@example.com',
          code: recovery_code,
          recovery_code: recovery_code,
          password: 'newpassword',
          password_confirm: 'newpassword'
        }

        expect(flash.now[:alert]).to eq('User not found')
        expect(response).to render_template(:code)
      end
    end
  end
end
