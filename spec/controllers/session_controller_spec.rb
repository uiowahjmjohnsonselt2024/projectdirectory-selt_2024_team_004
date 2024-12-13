require 'spec_helper'
require 'rails_helper'
require 'action_controller_workaround'

describe SessionsController, type: :controller do
  let(:user) {
    User.create(
      name: "Test User",
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )
  }

  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid credentials" do
      it "logs in the user and redirects to worlds path" do
        post :create, params: { email: user.email, password: "password" }

        expect(session[:session_token]).to eq(user.session_token)
        expect(session[:user_id]).to eq(user.id)
        expect(assigns(:current_user)).to eq(user)
        expect(response).to redirect_to(worlds_path(user_id: user.id))
        expect(flash[:notice]).to eq('Logged in successfully!')
      end
    end

    context "with invalid credentials" do
      it "does not log in the user and re-renders the new template" do
        post :create, params: { email: user.email, password: "wrongpassword" }

        expect(session[:session_token]).to be_nil
        expect(session[:user_id]).to be_nil
        expect(assigns(:current_user)).to be_nil
        expect(response).to render_template('new')
        expect(flash.now[:warning]).to eq('Invalid email or password')
      end
    end

    context "when user does not exist" do
      it "does not log in and re-renders the new view" do
        post :create, params: { email: "wrong@example.com", password: "password" }

        expect(session[:session_token]).to be_nil
        expect(session[:user_id]).to be_nil
        expect(assigns(:current_user)).to be_nil
        expect(response).to render_template('new')
        expect(flash.now[:warning]).to eq('Invalid email or password')
      end
    end
  end

  describe "DELETE #destroy" do
    it "logs out the user and redirects to the root path" do
      session[:session_token] = user.session_token
      session[:user_id] = user.id

      delete :destroy

      expect(session[:session_token]).to be_nil
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('Logged out successfully!')
    end
  end
end
