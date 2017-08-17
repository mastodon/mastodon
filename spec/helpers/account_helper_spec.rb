require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the AccountHelper. For example:
#
# describe AccountHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe AccountHelper, type: :helper do
  describe '#protocol_for_display' do
    it "returns OStatus when the protocol is 'ostatus'" do
      protocol = 'ostatus'
      expect(protocol_for_display(protocol)).to eq 'OStatus'
    end

    it "returns ActivityPub when the protocol is 'activitypub'" do
      protocol = 'activitypub'
      expect(protocol_for_display(protocol)).to eq 'ActivityPub'
    end

    it "returns the same string when the protocol is unknown" do
      protocol = 'wave'
      expect(protocol_for_display(protocol)).to eq protocol
    end
  end
end
