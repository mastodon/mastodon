# encoding: utf-8
# frozen_string_literal: true
require 'mail/encodings/identity'

module Mail
  module Encodings
    class Binary < Identity
      NAME = 'binary'
      PRIORITY = 5
      Encodings.register(NAME, self)
    end
  end
end
