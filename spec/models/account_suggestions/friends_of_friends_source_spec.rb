# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountSuggestions::FriendsOfFriendsSource do
  describe '#get' do
    subject { described_class.new }

    let!(:bob) { Fabricate(:account, discoverable: true, hide_collections: false) }
    let!(:alice) { Fabricate(:account, discoverable: true, hide_collections: true) }
    let!(:eve) { Fabricate(:account, discoverable: true, hide_collections: false) }
    let!(:mallory) { Fabricate(:account, discoverable: false, hide_collections: false) }
    let!(:eugen) { Fabricate(:account, discoverable: true, hide_collections: false) }
    let!(:neil) { Fabricate(:account, discoverable: true, hide_collections: false) }
    let!(:john) { Fabricate(:account, discoverable: true, hide_collections: false) }
    let!(:jerk) { Fabricate(:account, discoverable: true, hide_collections: false) }
    let!(:larry) { Fabricate(:account, discoverable: true, hide_collections: false) }
    let!(:morty) { Fabricate(:account, discoverable: true, hide_collections: false, memorial: true) }
    let!(:joyce) { Fabricate(:account, discoverable: true, hide_collections: false) }

    context 'with follows and blocks' do
      before do
        bob.block!(jerk)
        bob.request_follow!(joyce)
        FollowRecommendationMute.create!(account: bob, target_account: neil)

        # bob follows eugen, alice and larry
        [eugen, alice, larry].each { |account| bob.follow!(account) }

        # alice follows eve and mallory
        [john, mallory].each { |account| alice.follow!(account) }

        # eugen follows eve, john, jerk, larry, neil, morty and joyce
        [eve, mallory, jerk, larry, neil, morty, joyce].each { |account| eugen.follow!(account) }
      end

      it 'returns eligible accounts', :aggregate_failures do
        results = subject.get(bob)

        # eve is returned through eugen
        expect(results).to include([eve.id, :friends_of_friends])

        # john is not reachable because alice hides who she follows
        expect(results).to_not include([john.id, :friends_of_friends])

        # mallory is not discoverable
        expect(results).to_not include([mallory.id, :friends_of_friends])

        # larry is not included because he's followed already
        expect(results).to_not include([larry.id, :friends_of_friends])

        # jerk is blocked
        expect(results).to_not include([jerk.id, :friends_of_friends])

        # the suggestion for neil has already been rejected
        expect(results).to_not include([neil.id, :friends_of_friends])

        # morty is not included because his account is in memoriam
        expect(results).to_not include([morty.id, :friends_of_friends])

        # joyce is not included because there is already a pending follow request
        expect(results).to_not include([joyce.id, :friends_of_friends])
      end
    end

    context 'with deterministic order' do
      before do
        # bob follows eve and mallory
        [eve, mallory].each { |account| bob.follow!(account) }

        # eve follows eugen, john, and jerk
        [jerk, eugen, john].each { |account| eve.follow!(account) }

        # mallory follows eugen, john, and neil
        [neil, eugen, john].each { |account| mallory.follow!(account) }

        john.follow!(eugen)
        john.follow!(neil)
      end

      it 'returns eligible accounts in the expected order' do
        expect(subject.get(bob)).to eq expected_results
      end

      it 'contains correct underlying source data' do
        expect(source_query_values)
          .to contain_exactly(
            [john.id, 2, 2],  # Followed by 2 friends of bob (eve, mallory), 2 followers total (breaks tie)
            [eugen.id, 2, 3], # Followed by 2 friends of bob (eve, mallory), 3 followers total
            [jerk.id, 1, 1],  # Followed by 1 friends of bob (eve), 1 followers total (breaks tie)
            [neil.id, 1, 2]   # Followed by 1 friends of bob (mallory), 2 followers total
          )
      end

      def expected_results
        [
          [john.id, :friends_of_friends],
          [eugen.id, :friends_of_friends],
          [jerk.id, :friends_of_friends],
          [neil.id, :friends_of_friends],
        ]
      end

      def source_query_values
        subject.source_query(bob).to_a
      end
    end
  end
end
