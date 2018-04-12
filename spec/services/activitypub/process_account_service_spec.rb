require 'rails_helper'

RSpec.describe ActivityPub::ProcessAccountService do
  subject { described_class.new }

  context 'property values' do
    let(:payload) do
      {
        id: 'https://foo',
        type: 'Actor',
        inbox: 'https://foo/inbox',
        attachment: [
          { type: 'PropertyValue', name: 'Pronouns', value: 'They/them' },
          { type: 'PropertyValue', name: 'Occupation', value: 'Unit test' },
        ],
      }.with_indifferent_access
    end

    it 'parses out of attachment' do
      account = subject.call('alice', 'example.com', payload)
      expect(account.fields).to be_a Hash
      expect(account.fields).to include('Pronouns' => 'They/them')
      expect(account.fields).to include('Occupation' => 'Unit test')
    end
  end
end
