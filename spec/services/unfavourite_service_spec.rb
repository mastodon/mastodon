# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnfavouriteService do
  describe '#call' do
    context 'with a favourited status' do
      let(:status) { Fabricate(:status, account: account) }
      let!(:favourite) { Fabricate(:favourite, status: status) }

      context 'when the status account is local' do
        let(:account) { Fabricate(:account, domain: nil) }

        it 'destroys the favourite' do
          subject.call(favourite.account, status)

          expect { favourite.reload }
            .to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when the status account is a remote activitypub account' do
        let(:account) { Fabricate(:account, domain: 'host.example', protocol: :activitypub) }

        it 'destroys the favourite and sends a notification' do
          subject.call(favourite.account, status)

          expect { favourite.reload }
            .to raise_error(ActiveRecord::RecordNotFound)
          expect(ActivityPub::DeliveryWorker)
            .to have_enqueued_sidekiq_job(anything, favourite.account.id, status.account.inbox_url)
        end
      end
    end
  end
end
