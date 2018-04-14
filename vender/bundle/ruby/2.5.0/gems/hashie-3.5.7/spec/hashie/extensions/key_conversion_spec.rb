require 'spec_helper'
require 'support/module_context'

describe Hashie::Extensions::KeyConversion do
  include_context 'included hash module'

  it { should respond_to(:stringify_keys) }
  it { should respond_to(:stringify_keys!) }

  it { should respond_to(:symbolize_keys) }
  it { should respond_to(:symbolize_keys!) }
end
