# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomFilterImportValidator do
  subject { described_class.validate_each(record, :data, items) }

  let(:filter) do
    {
      'title' => title,
      'expires_at' => expires_at,
      'context' => context,
      'action' => action,
      'keywords_attributes' => keywords_attributes,
      'statuses' => statuses,
    }.except(*excluded_filter_attributes)
  end
  let(:title) { 'My filter' }
  let(:expires_at) { nil }
  let(:context) { ['home'] }
  let(:action) { 'warn' }
  let(:keywords_attributes) { [{ 'keyword' => 'foo', 'whole_word' => true }] }
  let(:statuses) { [] }
  let(:excluded_filter_attributes) { [] }

  let(:record_class) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :data

      def self.model_name
        ActiveModel::Name.new(self, nil, 'Record')
      end
    end
  end

  let(:record) { record_class.new }

  context 'when all items are valid' do
    let(:items) { [filter] }

    it 'does not add validation errors' do
      subject

      expect(record.errors[:data]).to be_empty
    end
  end

  context 'when the items are not an array' do
    let(:items) { 'not-an-array' }

    it 'adds an invalid type error' do
      subject

      expect(record.errors[:data].count).to eq(1)
      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.must_be_an_array'))
    end
  end

  context 'when an item is not a hash' do
    let(:items) { ['not-a-hash', filter] }

    it 'adds an error for the invalid index' do
      subject

      expect(record.errors[:data].count).to eq(1)
      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.must_be_a_hash'))
    end
  end

  context 'when an item is missing a required field' do
    # add test for each missing field
    # add test for each mistyped field

    let(:items) { [filter] }
    let(:excluded_filter_attributes) { ['expires_at'] }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data]).to include(
        a_string_starting_with(I18n.t('imports.errors.custom_filters.schema_error', index: 0, message: ''))
      )
    end
  end
end
