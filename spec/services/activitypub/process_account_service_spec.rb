require 'rails_helper'

RSpec.describe ActivityPub::ProcessAccountService, type: :service do
  subject { described_class.new }

  context 'property values' do
    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        attachment: [
          { type: 'PropertyValue', name: 'Pronouns', value: 'They/them' },
          { type: 'PropertyValue', name: 'Occupation', value: 'Unit test' },
        ],
      }.with_indifferent_access
    end

    it 'parses out of attachment' do
      account = subject.call('alice', 'example.com', payload)
      expect(account.fields).to be_a Array
      expect(account.fields.size).to eq 2
      expect(account.fields[0]).to be_a Account::Field
      expect(account.fields[0].name).to eq 'Pronouns'
      expect(account.fields[0].value).to eq 'They/them'
      expect(account.fields[1]).to be_a Account::Field
      expect(account.fields[1].name).to eq 'Occupation'
      expect(account.fields[1].value).to eq 'Unit test'
    end
  end
end
