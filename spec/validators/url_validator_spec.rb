# frozen_string_literal: true

require 'rails_helper'

RSpec.describe URLValidator do
  let(:record_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :profile

      validates :profile, url: true
    end
  end
  let(:record) { record_class.new }

  describe '#validate_each' do
    context 'with a nil value' do
      it 'adds errors' do
        record.profile = nil

        expect(record).to_not be_valid
        expect(record.errors.first.attribute).to eq(:profile)
        expect(record.errors.first.type).to eq(:invalid)
      end
    end

    context 'with an invalid url scheme' do
      it 'adds errors' do
        record.profile = 'ftp://example.com/page'

        expect(record).to_not be_valid
        expect(record.errors.first.attribute).to eq(:profile)
        expect(record.errors.first.type).to eq(:invalid)
      end
    end

    context 'without a hostname' do
      it 'adds errors' do
        record.profile = 'https:///page'

        expect(record).to_not be_valid
        expect(record.errors.first.attribute).to eq(:profile)
        expect(record.errors.first.type).to eq(:invalid)
      end
    end

    context 'with an unparseable value' do
      it 'adds errors' do
        record.profile = 'https://host:port/page' # non-numeric port string causes invalid uri error

        expect(record).to_not be_valid
        expect(record.errors.first.attribute).to eq(:profile)
        expect(record.errors.first.type).to eq(:invalid)
      end
    end

    context 'with a valid url' do
      it 'does not add errors' do
        record.profile = 'https://example.com/page'

        expect(record).to be_valid
        expect(record.errors).to be_empty
      end
    end
  end
end
