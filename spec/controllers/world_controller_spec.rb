require 'spec_helper'
require 'rails_helper'
require 'action_controller_workaround'

describe WorldsController type: controller do
  describe 'Creating a new world' do
    it "should yield a valid request when the create world button is selected" do
      get new_world_path
      response.should be_success
    end
    it 'should create a new world with my selected character options' do
    end
  end
  describe "Destroying a World" do
    it "should remove the given world from my lists of world upon deleting" do

    end
    describe "Accessing my world" do
      it "should provide me with a list of all my worlds" do

      end
    end
  end
end