# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scheduler::IndexingScheduler do
  let(:worker) { described_class.new }

  describe 'perform' do
    it 'runs without error' do
      expect { worker.perform }.to_not raise_error
    end
  end
end
