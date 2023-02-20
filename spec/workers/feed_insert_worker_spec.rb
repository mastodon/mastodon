# frozen_string_literal: true

require 'rails_helper'

describe FeedInsertWorker do
  subject { described_class.new }

  describe 'perform' do
    let(:follower) { Fabricate(:account) }
    let(:status) { Fabricate(:status) }

    context 'when there are no records' do
      it 'skips push with missing status' do
        instance = double(push_to_home: nil)
        allow(FeedManager).to receive(:instance).and_return(instance)
        result = subject.perform(nil, follower.id)

        expect(result).to be true
        expect(instance).to_not have_received(:push_to_home)
      end

      it 'skips push with missing account' do
        instance = double(push_to_home: nil)
        allow(FeedManager).to receive(:instance).and_return(instance)
        result = subject.perform(status.id, nil)

        expect(result).to be true
        expect(instance).to_not have_received(:push_to_home)
      end
    end

    context 'when there are real records' do
      it 'skips the push when there is a filter' do
        instance = double(push_to_home: nil, filter?: true)
        allow(FeedManager).to receive(:instance).and_return(instance)
        result = subject.perform(status.id, follower.id)

        expect(result).to be_nil
        expect(instance).to_not have_received(:push_to_home)
      end

      it 'pushes the status onto the home timeline without filter' do
        instance = double(push_to_home: nil, filter?: false)
        allow(FeedManager).to receive(:instance).and_return(instance)
        result = subject.perform(status.id, follower.id)

        expect(result).to be_nil
        expect(instance).to have_received(:push_to_home).with(follower, status, update: nil)
      end
    end
  end
end
