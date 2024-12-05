# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnualReport::TopStatuses do
  describe '#generate' do
    subject { described_class.new(account, Time.zone.now.year) }

    context 'with an inactive account' do
      let(:account) { Fabricate :account }

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            top_statuses: include(
              by_reblogs: be_nil,
              by_favourites: be_nil,
              by_replies: be_nil
            )
          )
      end
    end

    context 'with an active account' do
      let(:account) { Fabricate :account }

      let(:reblogged_status) { Fabricate :status, account: account }
      let(:favourited_status) { Fabricate :status, account: account }
      let(:replied_status) { Fabricate :status, account: account }

      before do
        _other = Fabricate :status
        reblogged_status.status_stat.update(reblogs_count: 123)
        favourited_status.status_stat.update(favourites_count: 123)
        replied_status.status_stat.update(replies_count: 123)
      end

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            top_statuses: include(
              by_reblogs: reblogged_status.id,
              by_favourites: favourited_status.id,
              by_replies: replied_status.id
            )
          )
      end
    end
  end
end
