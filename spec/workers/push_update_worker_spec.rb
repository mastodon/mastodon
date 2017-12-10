# frozen_string_literal: true

require 'rails_helper'

describe PushUpdateWorker do
  describe '#perform' do
    it 'publishes to the channel identified with the given key' do
      account = Fabricate(:account)
      status = Fabricate(:status)

      expect(Redis.current).to receive(:publish) do |key, message|
        expect(key).to eq 'the given key'
        expect(message).to be_a String
      end

      PushUpdateWorker.new.perform account.id, status.id, 'the given key'
    end

    it "publishes to the account's timeline if the given key is nil" do
      account = Fabricate(:account, id: 1)
      status = Fabricate(:status)

      expect(Redis.current).to receive(:publish) do |key, message|
        expect(key).to eq 'timeline:1'
        expect(message).to be_a String
      end

      PushUpdateWorker.new.perform account.id, status.id, nil
    end

    it 'does not raise an error even if the status is not found' do
      account = Fabricate(:account)
      status = Fabricate(:status)

      status.destroy!

      expect{ PushUpdateWorker.new.perform account.id, status.id }.not_to raise_error
    end
  end
end
