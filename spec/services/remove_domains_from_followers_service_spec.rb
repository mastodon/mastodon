# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoveDomainsFromFollowersService do
  describe '#call' do
    context 'with account followers' do
      let(:account) { Fabricate(:account, domain: nil) }
      let(:good_domain_account) { Fabricate(:account, domain: 'good.example', protocol: :activitypub) }
      let(:bad_domain_account) { Fabricate(:account, domain: 'bad.example', protocol: :activitypub) }

      before do
        Fabricate :follow, target_account: account, account: good_domain_account
        Fabricate :follow, target_account: account, account: bad_domain_account
      end

      it 'removes followers from supplied domains and sends a notification' do
        subject.call(account, ['bad.example'])

        expect(account.followers)
          .to include(good_domain_account)
          .and not_include(bad_domain_account)
        expect(ActivityPub::DeliveryWorker)
          .to have_enqueued_sidekiq_job(anything, account.id, bad_domain_account.inbox_url)
      end
    end
  end
end
