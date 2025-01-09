# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExistingUsernameValidator do
  let(:record_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :contact, :friends

      def self.name
        'Record'
      end

      validates :contact, existing_username: true
      validates :friends, existing_username: { multiple: true }
    end
  end
  let(:record) { record_class.new }

  describe '#validate_each' do
    context 'with a nil value' do
      it 'does not add errors' do
        record.contact = nil

        expect(record).to be_valid
        expect(record.errors).to be_empty
      end
    end

    context 'when there are no accounts' do
      it 'adds errors to the record' do
        record.contact = 'user@example.com'

        expect(record).to_not be_valid
        expect(record.errors.first.attribute).to eq(:contact)
        expect(record.errors.first.type).to eq I18n.t('existing_username_validator.not_found')
      end
    end

    context 'when there are accounts' do
      before { Fabricate(:account, domain: 'example.com', username: 'user') }

      context 'when the value does not match' do
        it 'adds errors to the record' do
          record.contact = 'friend@other.host'

          expect(record).to_not be_valid
          expect(record.errors.first.attribute).to eq(:contact)
          expect(record.errors.first.type).to eq I18n.t('existing_username_validator.not_found')
        end

        context 'when multiple is true' do
          it 'adds errors to the record' do
            record.friends = 'friend@other.host'

            expect(record).to_not be_valid
            expect(record.errors.first.attribute).to eq(:friends)
            expect(record.errors.first.type).to eq I18n.t('existing_username_validator.not_found_multiple', usernames: 'friend@other.host')
          end
        end
      end

      context 'when the value does match' do
        it 'does not add errors to the record' do
          record.contact = 'user@example.com'

          expect(record).to be_valid
          expect(record.errors).to be_empty
        end

        context 'when multiple is true' do
          it 'does not add errors to the record' do
            record.friends = 'user@example.com'

            expect(record).to be_valid
            expect(record.errors).to be_empty
          end
        end
      end
    end
  end
end
