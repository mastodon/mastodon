# frozen_string_literal: true

class Form::TwoFactorConfirmation
  include ActiveModel::Model

  attr_accessor :code

  def self.from_hash(hash)
    obj = new
    hash.each { |key, value| obj.send("#{key}=", value) }
    obj
  end
end
