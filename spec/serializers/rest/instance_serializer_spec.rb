# frozen_string_literal: true

require 'rails_helper'

describe REST::InstanceSerializer do
  let(:serialization) { serialized_record_json(record, described_class) }
  let(:record) { InstancePresenter.new }

  describe 'usage' do
    it 'returns recent usage data' do
      expect(serialization['usage']).to eq({ 'users' => { 'active_month' => 0 } })
    end

    it 'returns the VAPID public key' do
      expect(serialization['configuration']['vapid']).to eq({
        'public_key' => Rails.configuration.x.vapid_public_key,
      })
    end
  end
end
