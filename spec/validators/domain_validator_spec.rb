# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DomainValidator do
  let(:record) { record_class.new }

  context 'with no options' do
    let(:record_class) do
      Class.new do
        include ActiveModel::Validations

        attr_accessor :domain

        validates :domain, domain: true
      end
    end

    describe '#validate_each' do
      context 'with a nil value' do
        it 'does not add errors' do
          record.domain = nil

          expect(record).to be_valid
          expect(record.errors).to be_empty
        end
      end

      context 'with a valid domain' do
        it 'does not add errors' do
          record.domain = 'example.com'

          expect(record).to be_valid
          expect(record.errors).to be_empty
        end
      end

      context 'with a domain that is too long' do
        it 'adds an error' do
          record.domain = "#{'a' * 300}.com"

          expect(record).to_not be_valid
          expect(record.errors.where(:domain)).to_not be_empty
        end
      end

      context 'with a domain with an empty segment' do
        it 'adds an error' do
          record.domain = '.example.com'

          expect(record).to_not be_valid
          expect(record.errors.where(:domain)).to_not be_empty
        end
      end

      context 'with a domain with an invalid character' do
        it 'adds an error' do
          record.domain = '*.example.com'

          expect(record).to_not be_valid
          expect(record.errors.where(:domain)).to_not be_empty
        end
      end

      context 'with a domain that would fail parsing' do
        it 'adds an error' do
          record.domain = '/'

          expect(record).to_not be_valid
          expect(record.errors.where(:domain)).to_not be_empty
        end
      end
    end
  end

  context 'with acct option' do
    let(:record_class) do
      Class.new do
        include ActiveModel::Validations

        attr_accessor :acct

        validates :acct, domain: { acct: true }
      end
    end

    describe '#validate_each' do
      context 'with a nil value' do
        it 'does not add errors' do
          record.acct = nil

          expect(record).to be_valid
          expect(record.errors).to be_empty
        end
      end

      context 'with no domain' do
        it 'does not add errors' do
          record.acct = 'hoge_123'

          expect(record).to be_valid
          expect(record.errors).to be_empty
        end
      end

      context 'with a valid domain' do
        it 'does not add errors' do
          record.acct = 'hoge_123@example.com'

          expect(record).to be_valid
          expect(record.errors).to be_empty
        end
      end

      context 'with an invalid domain' do
        it 'adds an error' do
          record.acct = 'hoge_123@.example.com'

          expect(record).to_not be_valid
          expect(record.errors.where(:acct)).to_not be_empty
        end
      end
    end
  end
end
