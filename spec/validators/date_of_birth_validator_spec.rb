# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateOfBirthValidator do
  let(:record_class) do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :date_of_birth

      validates :date_of_birth, date_of_birth: true
    end
  end

  let(:record) { record_class.new }

  before do
    Setting.min_age = 16
  end

  describe '#validate_each' do
    context 'with an invalid date' do
      it 'adds errors' do
        record.date_of_birth = '76.830.10'

        expect(record).to_not be_valid
        expect(record.errors.first.attribute).to eq(:date_of_birth)
        expect(record.errors.first.type).to eq(:invalid)
      end
    end

    context 'with a date below age limit' do
      it 'adds errors' do
        record.date_of_birth = 13.years.ago.strftime('%d.%m.%Y')

        expect(record).to_not be_valid
        expect(record.errors.first.attribute).to eq(:date_of_birth)
        expect(record.errors.first.type).to eq(:below_limit)
      end
    end

    context 'with a date above age limit' do
      it 'does not add errors' do
        record.date_of_birth = 16.years.ago.strftime('%d.%m.%Y')

        expect(record).to be_valid
      end
    end
  end
end
