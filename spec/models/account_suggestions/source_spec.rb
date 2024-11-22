# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountSuggestions::Source do
  describe '#base_account_scope' do
    subject { FakeSource.new }

    before do
      stub_const 'FakeSource', fake_source_class
    end

    context 'with follows and follow requests' do
      let!(:account_domain_blocked_account) { Fabricate(:account, domain: 'blocked.host', discoverable: true) }
      let!(:account) { Fabricate(:account, discoverable: true) }
      let!(:blocked_account) { Fabricate(:account, discoverable: true) }
      let!(:eligible_account) { Fabricate(:account, discoverable: true) }
      let!(:follow_recommendation_muted_account) { Fabricate(:account, discoverable: true) }
      let!(:follow_requested_account) { Fabricate(:account, discoverable: true) }
      let!(:following_account) { Fabricate(:account, discoverable: true) }
      let!(:moved_account) { Fabricate(:account, moved_to_account: Fabricate(:account), discoverable: true) }
      let!(:silenced_account) { Fabricate(:account, silenced: true, discoverable: true) }
      let!(:undiscoverable_account) { Fabricate(:account, discoverable: false) }
      let!(:memorial_account) { Fabricate(:account, memorial: true, discoverable: true) }

      before do
        Fabricate :account_domain_block, account: account, domain: account_domain_blocked_account.domain
        Fabricate :block, account: account, target_account: blocked_account
        Fabricate :follow_recommendation_mute, account: account, target_account: follow_recommendation_muted_account
        Fabricate :follow_request, account: account, target_account: follow_requested_account
        Fabricate :follow, account: account, target_account: following_account
      end

      it 'returns eligible accounts' do
        results = subject.get(account)

        expect(results)
          .to include(eligible_account)
          .and not_include(account_domain_blocked_account)
          .and not_include(account)
          .and not_include(blocked_account)
          .and not_include(follow_recommendation_muted_account)
          .and not_include(follow_requested_account)
          .and not_include(following_account)
          .and not_include(moved_account)
          .and not_include(silenced_account)
          .and not_include(undiscoverable_account)
          .and not_include(memorial_account)
      end
    end
  end

  private

  def fake_source_class
    Class.new described_class do
      def get(account, limit: 10)
        base_account_scope(account)
          .limit(limit)
      end
    end
  end
end
