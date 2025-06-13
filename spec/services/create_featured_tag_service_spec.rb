# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateFeaturedTagService do
  describe '#call' do
    let(:tag) { 'test' }

    context 'with a local account' do
      let(:account) { Fabricate(:account, domain: nil) }

      it 'creates a new featured tag and distributes' do
        expect { subject.call(account, tag) }
          .to change(FeaturedTag, :count).by(1)
        expect(ActivityPub::AccountRawDistributionWorker)
          .to have_enqueued_sidekiq_job(anything, account.id)
      end
    end

    context 'with a remote account' do
      let(:account) { Fabricate(:account, domain: 'host.example') }

      it 'raises argument error' do
        expect { subject.call(account, tag) }
          .to raise_error ArgumentError
      end
    end
  end
end
