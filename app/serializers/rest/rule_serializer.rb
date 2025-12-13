# frozen_string_literal: true

class REST::RuleSerializer < ActiveModel::Serializer
  attributes :id, :text, :hint, :translations

  def id
    object.id.to_s
  end

  def translations
    object.translations.to_h do |translation|
      [translation.language, { text: translation.text, hint: translation.hint }]
    end
  end
end
