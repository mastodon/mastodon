require 'rails_helper'

RSpec.describe FetchAtomService do
  it 'returns nil if URL is blank'
  it 'processes URL'
  it 'retries without ActivityPub'
  it 'rescues SSL error'

  it 'rescues HTTP error' do
    expect(FetchAtomService.new.call('invalid')).to eq nil
  end
end
