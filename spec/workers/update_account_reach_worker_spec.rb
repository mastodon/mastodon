# frozen_string_literal: true

require 'rails_helper'

describe UpdateAccountReachWorker do
  subject { described_class.new }

  describe 'perform' do
    let(:account_reach_filter) { Fabricate(:account_reach_filter) }

    before do
      100.times { |i| redis.sadd("account_reach:#{account_reach_filter.id}:to_add", "test-domain-#{i}.org") }
    end

    it 'consolidates pending additions' do
      subject.perform(account_reach_filter.id)
      account_reach_filter.reload

      100.times { |i| expect(account_reach_filter.include?("test-domain-#{i}.org")).to be true }

      expect(account_reach_filter.include?('unknwon-domain.org')).to be false
    end
  end
end
