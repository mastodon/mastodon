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
    }
  end
  let(:title) { 'My filter' }
  let(:expires_at) { nil }
  let(:context) { ['home'] }
  let(:action) { 'warn' }
  let(:keywords_attributes) { [{ 'keyword' => 'foo', 'whole_word' => true }] }
  let(:statuses) { ['status1', 'status2'] }
  let(:items) { [filter] }

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
    it 'does not add validation errors' do
      subject

      expect(record.errors[:data]).to be_empty
    end
  end

  context 'when an item contains a field not defined in the schema' do
    let(:filter) { super().merge('unexpected_field' => 'value') }

    it 'does not add validation errors' do
      subject

      expect(record.errors[:data]).to be_empty
    end
  end

  context 'when items are not an array' do
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

  context 'when title is missing' do
    let(:filter) { super().except('title') }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when title contains the wrong type' do
    let(:title) { 123 }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when expires_at is missing' do
    let(:filter) { super().except('expires_at') }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when expires_at contains the wrong type' do
    let(:expires_at) { [] }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when context is missing' do
    let(:filter) { super().except('context') }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when context contains the wrong type' do
    let(:context) { 'home' }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when action is missing' do
    let(:filter) { super().except('action') }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when action contains the wrong type' do
    let(:action) { false }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when keywords_attributes is missing' do
    let(:filter) { super().except('keywords_attributes') }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when keywords_attributes contains the wrong type' do
    let(:keywords_attributes) { {} }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when statuses is missing' do
    let(:filter) { super().except('statuses') }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when statuses contains the wrong type' do
    let(:statuses) { 'status' }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when keyword is missing' do
    let(:keywords_attributes) { [{ 'whole_word' => true }] }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when keyword contains the wrong type' do
    let(:keywords_attributes) { [{ 'keyword' => 123, 'whole_word' => true }] }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when whole_word is missing' do
    let(:keywords_attributes) { [{ 'keyword' => 'foo' }] }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end

  context 'when whole_word contains the wrong type' do
    let(:keywords_attributes) { [{ 'keyword' => 'foo', 'whole_word' => 'true' }] }

    it 'adds a schema validation error with the item index' do
      subject

      expect(record.errors[:data])
        .to include(I18n.t('imports.errors.custom_filters.schema_error', index: 0))
    end
  end
end
