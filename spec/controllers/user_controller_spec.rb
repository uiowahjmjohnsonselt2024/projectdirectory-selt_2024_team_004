require 'spec_helper'
require 'rails_helper'
require 'action_controller_workaround'

describe UsersController, type: :controller do
  def create_user(attrs = {})
    User.create({
                  name: "Test User",
                  email: "test@example.com",
                  password: "password",
                  password_confirmation: "password"
                }.merge(attrs))
  end

  describe "GET #new" do
    it "assigns a new user to @user" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new user" do
        expect {
          post :create, params: {
            user: {
              name: "Test User",
              email: "test@example.com",
              password: "password",
              password_confirmation: "password"
            }
          }
        }.to change(User, :count).by(1)
      end

      it "redirects to the login path" do
        post :create, params: {
          user: {
            name: "Test User",
            email: "test@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to eq("Successfully created account!")
      end
    end

    context "with invalid attributes" do
      it "does not create a new user" do
        expect {
          post :create, params: {
            user: {
              name: " ",
              email: "invalid_email",
              password: "short",
              password_confirmation: "mismatch"
            }
          }
        }.not_to change(User, :count)
      end

      it "renders the new template with errors" do
        post :create, params: {
          user: {
            name: "",
            email: "invalid_email",
            password: "short",
            password_confirmation: "mismatch"
          }
        }
        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to include("Error")
      end
    end
  end
end
