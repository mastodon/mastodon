# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag do
  include_examples 'Reviewable'

  describe 'validations' do
    it 'invalid with #' do
      expect(described_class.new(name: '#hello_world')).to_not be_valid
    end

    it 'invalid with .' do
      expect(described_class.new(name: '.abcdef123')).to_not be_valid
    end

    it 'invalid with spaces' do
      expect(described_class.new(name: 'hello world')).to_not be_valid
    end

    it 'valid with ａｅｓｔｈｅｔｉｃ' do
      expect(described_class.new(name: 'ａｅｓｔｈｅｔｉｃ')).to be_valid
    end
  end

  describe '#to_param' do
    it 'returns name' do
      tag = Fabricate(:tag, name: 'foo')
      expect(tag.to_param).to eq 'foo'
    end
  end

  describe '#formatted_name' do
    it 'returns name with a proceeding hash symbol' do
      tag = Fabricate(:tag, name: 'foo')
      expect(tag.formatted_name).to eq '#foo'
    end

    it 'returns display_name with a proceeding hash symbol, if display name present' do
      tag = Fabricate(:tag, name: 'foobar', display_name: 'FooBar')
      expect(tag.formatted_name).to eq '#FooBar'
    end
  end

  describe '.recently_used' do
    let(:account) { Fabricate(:account) }
    let(:other_person_status) { Fabricate(:status) }
    let(:out_of_range) { Fabricate(:status, account: account) }
    let(:older_in_range) { Fabricate(:status, account: account) }
    let(:newer_in_range) { Fabricate(:status, account: account) }
    let(:unused_tag) { Fabricate(:tag) }
    let(:used_tag_one) { Fabricate(:tag) }
    let(:used_tag_two) { Fabricate(:tag) }
    let(:used_tag_on_out_of_range) { Fabricate(:tag) }

    before do
      stub_const 'Tag::RECENT_STATUS_LIMIT', 2

      other_person_status.tags << used_tag_one

      out_of_range.tags << used_tag_on_out_of_range

      older_in_range.tags << used_tag_one
      older_in_range.tags << used_tag_two

      newer_in_range.tags << used_tag_one
    end

    it 'returns tags used by account within last X statuses ordered most used first' do
      results = described_class.recently_used(account)

      expect(results)
        .to eq([used_tag_one, used_tag_two])
    end
  end

  describe '.find_normalized' do
    it 'returns tag for a multibyte case-insensitive name' do
      upcase_string   = 'abcABCａｂｃＡＢＣやゆよ'
      downcase_string = 'abcabcａｂｃａｂｃやゆよ'

      tag = Fabricate(:tag, name: HashtagNormalizer.new.normalize(downcase_string))
      expect(described_class.find_normalized(upcase_string)).to eq tag
    end
  end

  describe '.not_featured_by' do
    let!(:account) { Fabricate(:account) }
    let!(:fun) { Fabricate(:tag, name: 'fun') }
    let!(:games) { Fabricate(:tag, name: 'games') }

    before do
      Fabricate :featured_tag, account: account, name: 'games'
      Fabricate :featured_tag, name: 'fun'
    end

    it 'returns tags not featured by the account' do
      results = described_class.not_featured_by(account)

      expect(results)
        .to include(fun)
        .and not_include(games)
    end
  end

  describe '.matches_name' do
    it 'returns tags for multibyte case-insensitive names' do
      upcase_string   = 'abcABCａｂｃＡＢＣやゆよ'
      downcase_string = 'abcabcａｂｃａｂｃやゆよ'

      tag = Fabricate(:tag, name: HashtagNormalizer.new.normalize(downcase_string))
      expect(described_class.matches_name(upcase_string)).to eq [tag]
    end

    it 'uses the LIKE operator' do
      result = %q[SELECT "tags".* FROM "tags" WHERE LOWER("tags"."name") LIKE LOWER('100abc%')]
      expect(described_class.matches_name('100%abc').to_sql).to eq result
    end
  end

  describe '.matching_name' do
    it 'returns tags for multibyte case-insensitive names' do
      upcase_string   = 'abcABCａｂｃＡＢＣやゆよ'
      downcase_string = 'abcabcａｂｃａｂｃやゆよ'

      tag = Fabricate(:tag, name: HashtagNormalizer.new.normalize(downcase_string))
      expect(described_class.matching_name(upcase_string)).to eq [tag]
    end
  end

  describe '.find_or_create_by_names' do
    let(:upcase_string) { 'abcABCａｂｃＡＢＣやゆよ' }
    let(:downcase_string) { 'abcabcａｂｃａｂｃやゆよ' }

    it 'runs a passed block once per tag regardless of duplicates' do
      count = 0

      described_class.find_or_create_by_names([upcase_string, downcase_string]) do |_tag|
        count += 1
      end

      expect(count).to eq 1
    end
  end

  describe '.search_for' do
    it 'finds tag records with matching names' do
      tag = Fabricate(:tag, name: 'match')
      _miss_tag = Fabricate(:tag, name: 'miss')

      results = described_class.search_for('match')

      expect(results).to eq [tag]
    end

    it 'finds tag records in case insensitive' do
      tag = Fabricate(:tag, name: 'MATCH')
      _miss_tag = Fabricate(:tag, name: 'miss')

      results = described_class.search_for('match')

      expect(results).to eq [tag]
    end

    it 'finds the exact matching tag as the first item' do
      similar_tag = Fabricate(:tag, name: 'matchlater', reviewed_at: Time.now.utc)
      tag = Fabricate(:tag, name: 'match', reviewed_at: Time.now.utc)

      results = described_class.search_for('match')

      expect(results).to eq [tag, similar_tag]
    end

    it 'finds only listable tags' do
      tag = Fabricate(:tag, name: 'match')
      _miss_tag = Fabricate(:tag, name: 'matchunlisted', listable: false)

      results = described_class.search_for('match')

      expect(results).to eq [tag]
    end

    it 'finds non-listable tags as well via option' do
      tag = Fabricate(:tag, name: 'match')
      unlisted_tag = Fabricate(:tag, name: 'matchunlisted', listable: false)

      results = described_class.search_for('match', 5, 0, exclude_unlistable: false)

      expect(results).to eq [tag, unlisted_tag]
    end
  end
end
