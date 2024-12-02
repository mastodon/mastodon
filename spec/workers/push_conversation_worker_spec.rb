# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PushConversationWorker do
  let(:worker) { described_class.new }

  describe 'perform' do
    context 'with missing values' do
      it 'runs without error' do
        expect { worker.perform(nil) }
          .to_not raise_error
      end
    end

    context 'with valid records' do
      let(:account_conversation) { Fabricate :account_conversation }

      before { allow(redis).to receive(:publish) }

      it 'pushes message to timeline' do
        expect { worker.perform(account_conversation.id) }
          .to_not raise_error

        expect(redis)
          .to have_received(:publish)
          .with(redis_key, anything)
      end

      def redis_key
        "timeline:direct:#{account_conversation.account_id}"
      end
    end
  end
end
