# frozen_string_literal: true

class CustomFilterImportValidator
  FILTER_SCHEMA = {
    'type' => 'object',
    'required' => %w(title expires_at context action keywords_attributes statuses),
    'additionalProperties' => false,
    'properties' => {
      'title' => { 'type' => 'string' },
      'expires_at' => { 'type' => ['string', 'null'] },
      'context' => {
        'type' => 'array',
        'items' => { 'type' => 'string' },
      },
      'action' => { 'type' => 'string' },
      'keywords_attributes' => {
        'type' => 'array',
        'items' => {
          'type' => 'object',
          'required' => ['keyword', 'whole_word'],
          'additionalProperties' => false,
          'properties' => {
            'keyword' => { 'type' => 'string' },
            'whole_word' => { 'type' => 'boolean' },
          },
        },
      },
      'statuses' => {
        'type' => 'array',
        'items' => { 'type' => 'string' },
      },
    },
  }.freeze

  def self.validate_each(record, attribute, items)
    new.validate_each(record, attribute, items)
  end

  def validate_each(record, attribute, items)
    unless items.is_a?(Array)
      record.errors.add(attribute, I18n.t('imports.errors.custom_filters.must_be_an_array'))
      return
    end

    items.each_with_index do |item, index|
      next if valid_collection_item?(item)

      record.errors.add(
        attribute,
        I18n.t('imports.errors.custom_filters.schema_error', index: index)
      )
    end
  end

  private

  def valid_collection_item?(item)
    JSON::Validator
      .fully_validate(FILTER_SCHEMA, item)
      .blank?
  end
end
