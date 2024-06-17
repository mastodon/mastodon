# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Circle do
  it 'creates a corresponding list after creation' do
    circle = Fabricate(:circle)
    expect(circle.list).to be_present
    expect(circle.list.title).to eq(circle.title)
    expect(circle.list.account).to eq(circle.account)
  end
end
