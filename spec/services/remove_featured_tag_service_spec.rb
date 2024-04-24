# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoveFeaturedTagService do
  describe '#call' do
    context 'with a featured tag' do
      let(:featured_tag) { Fabricate(:featured_tag) }

      context 'when called by a local account' do
        let(:account) { Fabricate(:account, domain: nil) }

        it 'destroys the featured tag and sends a distribution' do
          subject.call(account, featured_tag)

          expect { featured_tag.reload }
            .to raise_error(ActiveRecord::RecordNotFound)
          expect(ActivityPub::AccountRawDistributionWorker)
            .to have_enqueued_sidekiq_job(anything, account.id)
        end
      end

      context 'when called by a non local account' do
        let(:account) { Fabricate(:account, domain: 'host.example') }

        it 'destroys the featured tag and does not send a distribution' do
          subject.call(account, featured_tag)

          expect { featured_tag.reload }
            .to raise_error(ActiveRecord::RecordNotFound)
          expect(ActivityPub::AccountRawDistributionWorker)
            .to_not have_enqueued_sidekiq_job(any_args)
        end
      end
    end
  end
end
