# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountReachFilter do
  describe 'basic functionality' do
    let(:filter) { Fabricate(:account_reach_filter) }

    it 'allows correct membership tests' do
      filter.add('mastodon.social')
      expect(filter.include?('mastodon.social')).to be true
      expect(filter.include?('mastodon.online')).to be false
    end

    it 'allows correct membership tests after save/reload' do
      filter.add('mastodon.social')
      filter.save!
      filter.reload
      expect(filter.include?('mastodon.social')).to be true
      expect(filter.include?('mastodon.online')).to be false
    end
  end
end
