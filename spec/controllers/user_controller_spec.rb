require 'spec_helper'
require 'rails_helper'
require 'action_controller_workaround'

describe UsersController do
  describe 'login and signup' do
    it 'should redirect me to create character upon adding a new world' do
      expect(User).to receive(:user_params).with('Ted').and_return(fake_results)
    end
  end
end