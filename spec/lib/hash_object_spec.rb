# frozen_string_literal: true

require 'rails_helper'

describe HashObject do
  it 'has methods corresponding to hash properties' do
    expect(HashObject.new(key: 'value').key).to eq 'value'
  end
end
