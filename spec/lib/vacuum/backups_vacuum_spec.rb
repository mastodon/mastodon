# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vacuum::BackupsVacuum do
  subject { described_class.new(retention_period) }

  let(:retention_period) { 7.days }

  describe '#perform' do
    let!(:expired_backup) { Fabricate(:backup, created_at: (retention_period + 1.day).ago) }
    let!(:current_backup) { Fabricate(:backup) }

    before do
      subject.perform
    end

    it 'deletes backups past the retention period' do
      expect { expired_backup.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'does not delete backups within the retention period' do
      expect { current_backup.reload }.to_not raise_error
    end
  end
end
