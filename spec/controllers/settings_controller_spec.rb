require 'spec_helper'
require 'rails_helper'
require 'action_controller_workaround'

describe SettingsController, type: :controller do
  let(:valid_character) { double('Character', image_code: 'character.png') }
  let(:valid_user) do
    User.create(
      name: 'Jane Doe',
      email: 'jane.doe@example.com',
      password: 'Password123!',
      password_confirmation: 'Password123!',
      default_currency: 'USD',
      session_token: 'valid_token_123'
    )
  end

  let(:valid_world) do
    World.create(
      world_name: 'World 1',
      last_played: DateTime.new(2024, 11, 29, 10, 0, 0),
      progress: 0
    )
  end

  before do
    session[:user_id] = valid_user.id
    session[:world_id] = valid_world.id
    session[:session_token] = valid_user.session_token
    allow(controller).to receive(:current_user).and_return(valid_user)
    allow(Character).to receive(:find_by).and_return(valid_character)
  end

  describe 'GET #show' do
    context 'when user is logged in' do
      before do
        allow(OpenExchangeService).to receive(:fetch_currencies).and_return(%w[USD EUR GBP])
      end

      it 'assigns @user and @currencies' do
        get :show, params: { return_path: '/some/path' }

        expect(assigns(:user)).to eq(valid_user)
        expect(assigns(:currencies)).to eq(%w[USD EUR GBP])
        expect(session[:return_path]).to eq('/some/path')
        expect(response).to have_http_status(:success)
      end

      it 'assigns @character_image' do
        get :show
        expect(assigns(:character_image)).to eq('character.png')
      end
    end
  end

  describe 'PATCH #update' do
    context 'when the update is successful' do
      before do
        allow(StoreService).to receive(:fetch_prices).and_return({ 'item1' => 10, 'item2' => 20 })
      end

      it 'updates the user’s default currency and retains the session token' do
        patch :update, params: { currency: 'EUR' }

        valid_user.reload
        expect(valid_user.default_currency).to eq('EUR')
        expect(valid_user.session_token).to eq(session[:session_token])
        expect(assigns(:prices)).to eq({ 'item1' => 10, 'item2' => 20 })
        expect(flash[:notice]).to eq('Settings saved successfully!')
        expect(response).to have_http_status(:success)
      end
    end

    context 'when the update fails' do
      it 'logs an error and displays an alert' do
        allow_any_instance_of(User).to receive(:update).and_return(false)

        patch :update, params: { currency: nil }

        expect(flash[:alert]).to eq('Could not save settings.')
        valid_user.reload
        expect(valid_user.default_currency).to eq('USD') # Currency remains unchanged
      end
    end
  end
end
