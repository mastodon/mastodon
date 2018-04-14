require 'spec_helper'

def a_method_to_match_against
  'Hello world!'
end

RSpec.describe Hashie::Utils do
  describe '.method_information' do
    it 'states the module or class that a native method was defined in' do
      bound_method = method(:trust)

      message = Hashie::Utils.method_information(bound_method)

      expect(message).to match('Kernel')
    end

    it 'states the line a Ruby method was defined at' do
      bound_method = method(:a_method_to_match_against)

      message = Hashie::Utils.method_information(bound_method)

      expect(message).to match('spec/hashie/utils_spec.rb')
    end
  end
end
