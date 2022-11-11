# frozen_string_literal: true

class RSS::Element
  def self.with(*args, &block)
    new(*args).tap(&block).to_element
  end

  def create_element(name, content = nil)
    Ox::Element.new(name).tap do |element|
      yield element if block_given?
      element << content if content.present?
    end
  end

  def append_element(name, content = nil)
    @root << create_element(name, content).tap do |element|
      yield element if block_given?
    end
  end

  def to_element
    @root
  end
end
