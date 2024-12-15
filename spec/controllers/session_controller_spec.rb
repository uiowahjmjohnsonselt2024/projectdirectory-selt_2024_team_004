require 'spec_helper'
require 'rails_helper'
require 'action_controller_workaround'

describe SessionsController, type: :controller do
  let(:user) do
    User.create(
      name: 'Test User',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'logs in the user and redirects to worlds path' do
        post :create, params: { email: user.email, password: 'password' }

        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(worlds_path)
        expect(flash[:notice]).to be_nil
      end
    end

    context 'with invalid credentials' do
      it 'does not log in the user and re-renders the new template' do
        post :create, params: { email: user.email, password: 'wrongpassword' }

        expect(session[:user_id]).to be_nil
        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq('Invalid email/password combination')
      end
    end

    context 'when user does not exist' do
      it 'does not log in and re-renders the new view' do
        post :create, params: { email: 'nonexistent@example.com', password: 'password' }

        expect(session[:user_id]).to be_nil
        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq('Invalid email/password combination')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'logs out the user and redirects to the root path' do
      session[:user_id] = user.id

      delete :destroy

      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq('You have been logged out')
    end
  end

  describe 'GET #recovery' do
    it 'renders the recovery template' do
      get :recovery
      expect(response).to render_template(:recovery)
    end
  end

  describe 'POST #recovery_code' do
    context 'when the user exists' do
      it 'sends a recovery email and redirects to the code path' do
        allow(UserMailer).to receive_message_chain(:recovery_email, :deliver_now)

        post :recovery_code, params: { email: user.email }

        expect(flash[:notice]).to eq("Recovery code sent to #{user.email}")
        expect(response).to redirect_to(code_path(email: user.email, code: assigns(:recovery_code)))
      end
    end

    context 'when the user does not exist' do
      it 're-renders the recovery template with an error' do
        post :recovery_code, params: { email: 'nonexistent@example.com' }

        expect(flash.now[:alert]).to eq('An account does not exist under that email')
        expect(response).to render_template(:recovery)
      end
    end
  end

  describe 'POST #verify' do
    context 'with valid recovery code and matching passwords' do
      it 'updates the user password and logs them in' do
        recovery_code = SecureRandom.hex(4)
        allow(UserMailer).to receive_message_chain(:recovery_email, :deliver_now)

        post :recovery_code, params: { email: user.email }
        post :verify, params: {
          email: user.email,
          code: recovery_code,
          recovery_code: recovery_code,
          password: 'newpassword',
          password_confirm: 'newpassword'
        }

        expect(user.reload.authenticate('newpassword')).to be_truthy
        expect(session[:user_id]).to eq(user.id)
        expect(flash[:notice]).to eq('Password successfully reset.')
        expect(response).to redirect_to(login_path)
      end
    end

    context 'with invalid recovery code or mismatched passwords' do
      it 're-renders the code template with an error' do
        post :verify, params: {
          email: user.email,
          code: 'invalid',
          recovery_code: 'recoverycode',
          password: 'newpassword',
          password_confirm: 'wrongpassword'
        }

        expect(session[:user_id]).to be_nil
        expect(flash.now[:alert]).to eq('Invalid recovery code or passwords do not match.')
        expect(response).to render_template(:code)
      end
    end
  end
end
