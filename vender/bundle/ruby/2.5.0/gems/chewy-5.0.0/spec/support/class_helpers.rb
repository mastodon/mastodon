module ClassHelpers
  extend ActiveSupport::Concern

  def stub_index(name, superclass = nil, &block)
    stub_class("#{name.to_s.camelize}Index", superclass || Chewy::Index)
      .tap { |i| i.class_eval(&block) if block }
  end

  def stub_class(name, superclass = nil, &block)
    stub_const(name.to_s.camelize, Class.new(superclass || Object, &block))
  end

  def stub_model(_name, _superclass = nil)
    raise NotImplementedError, 'Seems like no ORM/ODM are loaded, please check your Gemfile'
  end
end
