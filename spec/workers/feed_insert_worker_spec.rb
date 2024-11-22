# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedInsertWorker do
  subject { described_class.new }

  describe 'perform' do
    let(:follower) { Fabricate(:account) }
    let(:status) { Fabricate(:status) }
    let(:list) { Fabricate(:list) }

    context 'when there are no records' do
      it 'skips push with missing status' do
        instance = instance_double(FeedManager, push_to_home: nil)
        allow(FeedManager).to receive(:instance).and_return(instance)
        result = subject.perform(nil, follower.id)

        expect(result).to be true
        expect(instance).to_not have_received(:push_to_home)
      end

      it 'skips push with missing account' do
        instance = instance_double(FeedManager, push_to_home: nil)
        allow(FeedManager).to receive(:instance).and_return(instance)
        result = subject.perform(status.id, nil)

        expect(result).to be true
        expect(instance).to_not have_received(:push_to_home)
      end
    end

    context 'when there are real records' do
      it 'skips the push when there is a filter' do
        instance = instance_double(FeedManager, push_to_home: nil, filter?: true)
        allow(FeedManager).to receive(:instance).and_return(instance)
        result = subject.perform(status.id, follower.id)

        expect(result).to be_nil
        expect(instance).to_not have_received(:push_to_home)
      end

      it 'pushes the status onto the home timeline without filter' do
        instance = instance_double(FeedManager, push_to_home: nil, filter?: false)
        allow(FeedManager).to receive(:instance).and_return(instance)
        result = subject.perform(status.id, follower.id, :home)

        expect(result).to be_nil
        expect(instance).to have_received(:push_to_home).with(follower, status, update: nil)
      end

      it 'pushes the status onto the tags timeline without filter' do
        instance = instance_double(FeedManager, push_to_home: nil, filter?: false)
        allow(FeedManager).to receive(:instance).and_return(instance)
        result = subject.perform(status.id, follower.id, :tags)

        expect(result).to be_nil
        expect(instance).to have_received(:push_to_home).with(follower, status, update: nil)
      end

      it 'pushes the status onto the list timeline without filter' do
        instance = instance_double(FeedManager, push_to_list: nil, filter?: false)
        allow(FeedManager).to receive(:instance).and_return(instance)
        result = subject.perform(status.id, list.id, :list)

        expect(result).to be_nil
        expect(instance).to have_received(:push_to_list).with(list, status, update: nil)
      end
    end
  end
end
