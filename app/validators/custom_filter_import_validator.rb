# frozen_string_literal: true

class CustomFilterImportValidator
  FILTER_SCHEMA = {
    'type' => 'object',
    'required' => %w(title expires_at context action keywords_attributes statuses),
    'additionalProperties' => true,
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
          'additionalProperties' => true,
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
    unless items.is_a?(Array)
      record.errors.add(attribute, I18n.t('imports.errors.custom_filters.must_be_an_array'))
      return
    end

    items.each_with_index do |item, index|
      unless item.is_a?(Hash)
        record.errors.add(
          attribute,
          I18n.t('imports.errors.custom_filters.must_be_a_hash')
        )
        next
      end

      schema_errors = JSON::Validator.fully_validate(FILTER_SCHEMA, item)

      schema_errors.each do |_error_message|
        record.errors.add(
          attribute,
          I18n.t('imports.errors.custom_filters.schema_error', index: index)
        )
      end
    end
  end
end
