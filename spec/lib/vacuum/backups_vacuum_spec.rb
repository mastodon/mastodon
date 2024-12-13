# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vacuum::BackupsVacuum do
  subject { described_class.new(retention_period) }

  let(:retention_period) { 7.days }

  describe '#perform' do
    let!(:expired_backup) { Fabricate(:backup, created_at: (retention_period + 1.day).ago) }
    let!(:current_backup) { Fabricate(:backup) }

    it 'deletes backups past the retention period but preserves those within the period' do
      subject.perform

      expect { expired_backup.reload }
        .to raise_error ActiveRecord::RecordNotFound
      expect { current_backup.reload }
        .to_not raise_error
    end
  end
end
