# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportNote do
  describe 'Scopes' do
    describe '.chronological' do
      it 'returns report notes oldest to newest' do
        report = Fabricate(:report)
        note1 = Fabricate(:report_note, report: report)
        note2 = Fabricate(:report_note, report: report)

        expect(report.notes.chronological).to eq [note1, note2]
      end
    end
  end

  describe 'Validations' do
    subject { Fabricate.build :report_note }

    describe 'content' do
      it { is_expected.to_not allow_value('').for(:content) }
      it { is_expected.to validate_length_of(:content).is_at_most(described_class::CONTENT_SIZE_LIMIT) }
    end
  end
end
