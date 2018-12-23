# frozen_string_literal: true

class CustomEmojiFilter
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = CustomEmoji.alphabetic

    params.each do |key, value|
      scope.merge!(scope_for(key, value)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'local'
      CustomEmoji.local
    when 'remote'
      CustomEmoji.remote
    when 'by_domain'
      CustomEmoji.where(domain: value)
    else
      raise "Unknown filter: #{key}"
    end
  end
end
