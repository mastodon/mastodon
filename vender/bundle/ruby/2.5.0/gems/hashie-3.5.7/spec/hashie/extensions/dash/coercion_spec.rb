require 'spec_helper'

describe Hashie::Extensions::Dash::Coercion do
  class DashWithCoercion < Hashie::Dash
    include Hashie::Extensions::Dash::Coercion

    property :type, coerce: Symbol
  end

  it 'does the coercion of properties' do
    expect(DashWithCoercion.new(type: 'something')).to eq(type: :something)
  end
end
