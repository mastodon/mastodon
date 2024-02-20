# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountSuggestions::FriendsOfFriendsSource do
  describe '#base_account_scope' do
    subject { described_class.new }

    context 'with follows and follow requests' do
      let!(:bob) { Fabricate(:account, discoverable: true, hide_collections: false) }
      let!(:alice) { Fabricate(:account, discoverable: true, hide_collections: true) }
      let!(:eve) { Fabricate(:account, discoverable: true, hide_collections: false) }
      let!(:mallory) { Fabricate(:account, discoverable: false, hide_collections: false) }
      let!(:eugen) { Fabricate(:account, discoverable: true, hide_collections: false) }
      let!(:john) { Fabricate(:account, discoverable: true, hide_collections: false) }
      let!(:jerk) { Fabricate(:account, discoverable: true, hide_collections: false) }
      let!(:neil) { Fabricate(:account, discoverable: true, hide_collections: false) }

      before do
        bob.block!(jerk)
        FollowRecommendationMute.create!(account: bob, target_account: neil)

        # bob follows eugen and alice
        [eugen, alice].each { |account| bob.follow!(account) }

        # alice follows eve and mallory
        [john, mallory].each { |account| alice.follow!(account) }

        # eugen follows eve, john, jerk and neil
        [eve, mallory, jerk, neil].each { |account| eugen.follow!(account) }
      end

      it 'returns eligible accounts', :aggregate_failures do
        results = subject.get(bob)

        # eve is returned through eugen
        expect(results).to include([eve.id, :friends_of_friends])

        # john is not reachable because alice hides who she follows
        expect(results).to_not include([john.id, :friends_of_friends])

        # mallory is not discoverable
        expect(results).to_not include([mallory.id, :friends_of_friends])

        # jerk is blocked
        expect(results).to_not include([jerk.id, :friends_of_friends])

        # the suggestion for neil has already been rejected
        expect(results).to_not include([neil.id, :friends_of_friends])
      end
    end
  end
end
