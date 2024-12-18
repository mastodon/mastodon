# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PushUpdateWorker do
  let(:worker) { described_class.new }

  describe 'perform' do
    it 'runs without error for missing record' do
      account_id = nil
      status_id = nil

      expect { worker.perform(account_id, status_id) }.to_not raise_error
    end
  end
end
