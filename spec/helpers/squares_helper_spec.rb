require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SquaresHelper. For example:
#
# describe SquaresHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SquaresHelper, type: :helper do
  it 'adds an example test' do
    expect(true).to be(true)
  end
end
