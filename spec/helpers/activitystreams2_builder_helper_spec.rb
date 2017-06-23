# frozen_string_literal: true

require 'rails_helper'

describe Activitystreams2BuilderHelper, type: :helper do
  it 'returns display name if present' do
    account = Fabricate(:account, display_name: 'display name', username: 'username')
    expect(account_name(account)).to eq 'display name'
  end

  it 'returns username if display name is not present' do
    account = Fabricate(:account, display_name: '', username: 'username')
    expect(account_name(account)).to eq 'username'
  end
end
