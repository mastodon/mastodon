# frozen_string_literal: true

require 'rails_helper'

describe PollExpirationNotifyWorker do
  let(:worker) { described_class.new }

  describe 'perform' do
    it 'runs without error for missing record' do
      expect { worker.perform(nil) }.to_not raise_error
    end
  end
end
