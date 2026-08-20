# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account, '#fields' do
  subject { Fabricate.build :account }

  describe 'Validations' do
    context 'when account is local' do
      subject { Fabricate.build :account, domain: nil }

      it { is_expected.to allow_value(fields_empty_name_value).for(:fields) }
      it { is_expected.to_not allow_values(fields_over_limit, fields_empty_name).for(:fields) }

      def fields_empty_name_value
        Array.new(described_class::DEFAULT_FIELDS_SIZE) { %w(name value).index_with('') }
      end

      def fields_over_limit
        Array.new(described_class::DEFAULT_FIELDS_SIZE + 1) { { 'name' => 'Name', 'value' => 'Value', 'verified_at' => '01/01/1970' } }
      end

      def fields_empty_name
        [{ 'name' => '', 'value' => 'Value', 'verified_at' => '01/01/1970' }]
      end
    end
  end

  describe '#fields' do
    subject { account.fields }

    let(:account) { Fabricate.build :account }

    context 'when attribute is nil' do
      before { account.fields = nil }

      it { is_expected.to be_empty }
    end

    context 'when attribute has valid data' do
      before { account.fields = [{ 'name' => 'Personal Web Site', 'value' => 'https://host.example' }] }

      it 'returns array of account field objects' do
        expect(subject)
          .to be_an(Array)
          .and contain_exactly(
            be_a(Account::Field).and(have_attributes(name: /Personal/, value: /host.example/))
          )
      end
    end

    context 'when attribute has invalid data' do
      before { account.fields = [{ 'blurp' => 'zorp', '@@@@' => '###' }] }

      it { is_expected.to be_empty }
    end
  end

  describe '#fields_attributes=' do
    let(:account) { Fabricate.build :account }

    context 'when sent empty hash' do
      it 'assigns empty array to fields' do
        account.fields_attributes = {}

        expect(account.fields)
          .to be_empty
      end
    end

    context 'when sent indexed hash' do
      it 'assigns fields array' do
        account.fields_attributes = {
          '0' => { name: 'Color', value: 'Red' },
          '1' => { name: 'Size', value: 'Medium' },
        }

        expect(account.fields)
          .to be_an(Array)
          .and contain_exactly(
            be_a(Account::Field).and(have_attributes(name: /Color/, value: /Red/)),
            be_a(Account::Field).and(have_attributes(name: /Size/, value: /Medium/))
          )
      end
    end

    context 'when sent indexed hash with missing values' do
      it 'rejects blanks and assigns fields array' do
        account.fields_attributes = {
          '0' => { name: 'Color', value: 'Red' },
          '1' => { name: '', value: '' },
        }

        expect(account.fields)
          .to be_an(Array)
          .and contain_exactly(
            be_a(Account::Field).and(have_attributes(name: /Color/, value: /Red/))
          )
      end
    end

    context 'when sent array of field hashes' do
      it 'assigns fields array' do
        account.fields_attributes = [
          { name: 'Color', value: 'Red' },
          { name: 'Size', value: 'Medium' },
        ]

        expect(account.fields)
          .to be_an(Array)
          .and contain_exactly(
            be_a(Account::Field).and(have_attributes(name: /Color/, value: /Red/)),
            be_a(Account::Field).and(have_attributes(name: /Size/, value: /Medium/))
          )
      end
    end

    context 'when fields were previously a hash' do
      before { account.fields = {} }

      it 'assigns fields array' do
        account.fields_attributes = {
          '0' => { name: 'Color', value: 'Red' },
        }

        expect(account.fields)
          .to be_an(Array)
          .and contain_exactly(
            be_a(Account::Field).and(have_attributes(name: /Color/, value: /Red/))
          )
      end
    end

    context 'when fields were previously verified' do
      before { account.fields = [{ name: 'Color', value: 'Red', verified_at: 2.weeks.ago.to_datetime }] }

      it 'assigns fields array with preserved verification' do
        account.fields_attributes = {
          '0' => { name: 'Color', value: 'Red' },
        }

        expect(account.fields)
          .to be_an(Array)
          .and contain_exactly(
            be_a(Account::Field).and(have_attributes(name: /Color/, value: /Red/, verified_at: 2.weeks.ago.to_datetime).and(be_verified))
          )
      end
    end
  end

  describe '#build_fields' do
    let(:account) { Fabricate.build :account }

    before { stub_const('Account::DEFAULT_FIELDS_SIZE', 4) }

    context 'when fields already full' do
      before { account.fields = Array.new(Account::DEFAULT_FIELDS_SIZE) { |i| { name: "Name#{i}", value: 'Test' } } }

      it 'returns nil without updating fields' do
        expect(account.build_fields)
          .to be_nil

        expect(account.fields)
          .to be_an(Array)
          .and have_attributes(size: Account::DEFAULT_FIELDS_SIZE)
      end
    end

    context 'when fields partially full' do
      before { account.fields = Array.new(2) { |i| { name: "Name#{i}", value: 'Test' } } }

      it 'returns nil without updating fields' do
        expect(account.build_fields)
          .to be_an(Array)

        expect(account.attributes['fields'])
          .to be_an(Array)
          .and contain_exactly(
            include('name' => /Name/),
            include('name' => /Name/),
            include('name' => ''),
            include('name' => '')
          )
      end
    end

    context 'when fields were previously a hash' do
      before { account.fields = {} }

      it 'assigns fields array with empty values' do
        expect(account.build_fields)
          .to be_an(Array)

        expect(account.attributes['fields'])
          .to be_an(Array)
          .and all(include('name' => '', 'value' => ''))
      end
    end
  end
end
