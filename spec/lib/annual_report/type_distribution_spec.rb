# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnualReport::TypeDistribution do
  describe '#generate' do
    subject { described_class.new(account, Time.zone.now.year) }

    context 'with an inactive account' do
      let(:account) { Fabricate :account }

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            type_distribution: include(
              total: 0,
              reblogs: 0,
              replies: 0,
              standalone: 0
            )
          )
      end
    end

    context 'with an active account' do
      let(:account) { Fabricate :account }

      before do
        _other = Fabricate :status
        Fabricate :status, reblog: Fabricate(:status), account: account
        Fabricate :status, in_reply_to_id: Fabricate(:status).id, account: account, reply: true
        Fabricate :status, account: account
      end

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            type_distribution: include(
              total: 3,
              reblogs: 1,
              replies: 1,
              standalone: 1
            )
          )
      end
    end
  end
end
