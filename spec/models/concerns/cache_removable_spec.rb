# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CacheRemovable do
  describe '#remove_blocking_cache' do
    expectations = [OpenStruct.new(klass: :account_domain_block, head: 'exclude_domains_for'),
                    OpenStruct.new(klass: :block,                head: 'exclude_account_ids_for'),
                    OpenStruct.new(klass: :mute,                 head: 'exclude_account_ids_for')]

    expectations.each do |expectation|
      obj  = Fabricate(expectation.klass)
      tail = obj.account_id

      it "removes #{expectation.klass} blocking cache" do
        Rails.cache.write("#{expectation.head}:#{tail}", [])

        obj.send(:remove_blocking_cache, expectation.head, tail)
        expect(Rails.cache.exist?("#{expectation.head}:#{tail}")).to eq false
      end
    end
  end
end
