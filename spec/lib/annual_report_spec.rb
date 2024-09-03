# frozen_string_literal: true

require 'rails_helper'

describe AnnualReport do
  describe '#generate' do
    subject { described_class.new(account, Time.zone.now.year) }

    let(:account) { Fabricate :account }

    it 'builds a report for an account' do
      expect { subject.generate }
        .to change(GeneratedAnnualReport, :count).by(1)
    end
  end
end
