require 'spec_helper'
require 'rails_helper'
require 'action_controller_workaround'

describe WorldsController, type: controller do
  let(:user) {
    User.create(
      name: "Test User",
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )
  }
end