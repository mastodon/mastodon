# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagRelationshipsPresenter do
  context 'without an account' do
    subject { described_class.new(tags, nil) }

    let(:tags) { Fabricate.times 2, :tag }

    it 'includes empty hashes for maps' do
      expect(subject)
        .to have_attributes(
          following_map: eq({}),
          featuring_map: eq({})
        )
    end
  end

  context 'with an account and following and featured tags' do
    subject { described_class.new(Tag.all, account.id) }

    let(:account) { Fabricate :account }
    let(:tag_to_feature) { Fabricate :tag }
    let(:tag_to_follow) { Fabricate :tag }

    before do
      Fabricate :featured_tag, account: account, tag: tag_to_feature
      Fabricate :tag_follow, account: account, tag: tag_to_follow
    end

    it 'includes map with relevant id values' do
      expect(subject)
        .to have_attributes(
          featuring_map: eq(tag_to_feature.id => true),
          following_map: eq(tag_to_follow.id => true)
        )
    end
  end
end
