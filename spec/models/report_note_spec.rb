# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportNote do
  describe 'chronological scope' do
    it 'returns report notes oldest to newest' do
      report = Fabricate(:report)
      note1 = Fabricate(:report_note, report: report)
      note2 = Fabricate(:report_note, report: report)

      expect(report.notes.chronological).to eq [note1, note2]
    end
  end

  describe 'validations' do
    it 'is invalid if the content is empty' do
      report = Fabricate.build(:report_note, content: '')
      expect(report.valid?).to be false
    end

    it 'is invalid if content is longer than character limit' do
      report = Fabricate.build(:report_note, content: comment_over_limit)
      expect(report.valid?).to be false
    end

    def comment_over_limit
      Faker::Lorem.paragraph_by_chars(number: described_class::CONTENT_SIZE_LIMIT * 2)
    end
  end
end
