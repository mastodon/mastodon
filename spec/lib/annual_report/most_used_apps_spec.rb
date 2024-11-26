# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnualReport::MostUsedApps do
  describe '#generate' do
    subject { described_class.new(account, Time.zone.now.year) }

    context 'with an inactive account' do
      let(:account) { Fabricate :account }

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            most_used_apps: be_an(Array).and(be_empty)
          )
      end
    end

    context 'with an active account' do
      let(:account) { Fabricate :account }

      let(:application) { Fabricate :application, name: 'App' }
      let(:most_application) { Fabricate :application, name: 'Most App' }

      before do
        _other = Fabricate :status
        Fabricate.times 2, :status, account: account, application: application
        Fabricate.times 3, :status, account: account, application: most_application
      end

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            most_used_apps: eq(
              [
                { name: most_application.name, count: 3 },
                { name: application.name, count: 2 },
              ]
            )
          )
      end
    end
  end
end
