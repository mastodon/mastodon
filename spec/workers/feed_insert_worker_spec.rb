# frozen_string_literal: true

require 'rails_helper'

describe FeedInsertWorker do
  subject { described_class.new }

  describe 'perform' do
    let(:follower) { Fabricate(:account) }
    let(:status) { Fabricate(:status) }

    context 'when there are no records' do
      it 'skips push with missing status' do
        instance = double(push: nil)
        allow(FeedManager).to receive(:instance).and_return(instance)
        result = subject.perform(nil, follower.id)

        expect(result).to eq true
        expect(instance).not_to have_received(:push)
      end

      it 'skips push with missing account' do
        instance = double(push: nil)
        allow(FeedManager).to receive(:instance).and_return(instance)
        result = subject.perform(status.id, nil)

        expect(result).to eq true
        expect(instance).not_to have_received(:push)
      end
    end

    context 'when there are real records' do
      it 'skips the push when there is a filter'
      it 'pushes the status onto the home timeline without filter'
    end
  end
end
