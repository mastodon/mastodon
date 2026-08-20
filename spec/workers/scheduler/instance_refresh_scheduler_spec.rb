# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scheduler::InstanceRefreshScheduler do
  let(:worker) { described_class.new }

  describe 'perform' do
    it 'runs without error' do
      expect { worker.perform }
        .to_not raise_error
    end
  end

  context 'with elasticsearch enabled', :search do
    before { Fabricate :remote_account }

    it 'updates search indexes' do
      expect { worker.perform }
        .to change(InstancesIndex, :count).by(1)
    end
  end
end
