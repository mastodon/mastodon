# frozen_string_literal: true

class ValidationErrorFormatter
  def initialize(error, aliases = {})
    @error   = error
    @aliases = aliases
  end

  def as_json
    { error: @error.to_s, details: details }
  end

  private

  def details
    h = {}

    errors.details.each_pair do |attribute_name, attribute_errors|
      messages = errors.messages[attribute_name]

      h[@aliases[attribute_name] || attribute_name] = attribute_errors.map.with_index do |error, index|
        { error: 'ERR_' + error[:error].to_s.upcase, description: messages[index] }
      end
    end

    h
  end

  def errors
    @errors ||= @error.record.errors
  end
end
