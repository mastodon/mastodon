# frozen_string_literal: true

require 'rails_helper'

describe FeedInsertWorker do
  subject { described_class.new }

  describe 'perform' do
    let(:followers) { [Fabricate(:account), Fabricate(:account)] }
    let(:status) { Fabricate(:status) }

    it 'skips push when there are no records' do
      instance = double(push: nil)
      allow(FeedManager).to receive(:instance).and_return(instance)
      result = subject.perform(nil, followers.map(&:id))

      expect(result).to eq true
      expect(instance).not_to have_received(:push)
    end

    it 'skips push when there are no accounts' do
      instance = double(push: nil)
      allow(FeedManager).to receive(:instance).and_return(instance)
      result = subject.perform(status, [])

      expect(result).to eq true
      expect(instance).not_to have_received(:push)
    end

    it 'pushes with records' do
      instance = double(push: nil)
      allow(FeedManager).to receive(:instance).and_return(instance)
      result = subject.perform(status.id, followers.map(&:id))

      expect(result).to be_nil
      expect(instance).to have_received(:push).with(:home, followers, status)
    end
  end
end
