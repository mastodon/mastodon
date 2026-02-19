# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PushUpdateWorker do
  let(:worker) { described_class.new }

  describe 'perform' do
    context 'with missing values' do
      it 'runs without error' do
        expect { worker.perform(nil, nil) }
          .to_not raise_error
      end
    end

    context 'with valid records' do
      let(:account) { Fabricate :account }
      let(:status) { Fabricate :status }

      before { allow(redis).to receive(:publish) }

      it 'pushes message to timeline' do
        expect { worker.perform(account.id, status.id) }
          .to_not raise_error

        expect(redis)
          .to have_received(:publish)
          .with(redis_key, anything)
      end

      def redis_key
        "timeline:#{account.id}"
      end
    end
  end
end
