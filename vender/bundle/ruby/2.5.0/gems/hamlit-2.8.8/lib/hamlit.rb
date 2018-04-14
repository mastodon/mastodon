# frozen_string_literal: true
require 'hamlit/engine'
require 'hamlit/error'
require 'hamlit/version'
require 'hamlit/template'

begin
  require 'rails'
  require 'hamlit/railtie'
rescue LoadError
end
