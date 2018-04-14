# frozen_string_literal: true
require 'rails'

module Hamlit
  class Railtie < ::Rails::Railtie
    initializer :hamlit do |app|
      require 'hamlit/rails_template'
    end
  end
end
