# frozen_string_literal: true

class ObfuscatedDomainPresenter
  attr_reader :domain, :placeholder

  PRESERVED_CHARACTERS = %w(.).freeze
  VISIBLE_WINDOW_EDGE = 4

  def initialize(domain, placeholder: '*')
    @domain = domain
    @placeholder = placeholder
  end

  def to_s
    domain_characters
      .with_index { |character, index| solution(character, index) }
      .join
  end

  private

  def solution(character, index)
    if midstream?(index) && PRESERVED_CHARACTERS.exclude?(character)
      placeholder
    else
      character
    end
  end

  def midstream?(index)
    index > visible_ratio && index < ending_boundary
  end

  def domain_characters
    domain.chars.map
  end

  def length
    @length ||= domain.size
  end

  def visible_ratio
    @visible_ratio ||= length / VISIBLE_WINDOW_EDGE
  end

  def ending_boundary
    @ending_boundary ||= length - visible_ratio
  end
end
