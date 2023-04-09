# frozen_string_literal: true

require 'rails_helper'

describe Admin::SystemCheck::Message do
  subject(:check) { described_class.new(:key_value, :value_value, :action_value, :critical_value) }

  it 'providers readers when initialized' do
    expect(check.key).to eq :key_value
    expect(check.value).to eq :value_value
    expect(check.action).to eq :action_value
    expect(check.critical).to eq :critical_value
  end
end
