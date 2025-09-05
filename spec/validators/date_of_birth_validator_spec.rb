# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateOfBirthValidator, type: :model do
  subject { Fabricate.build :user }

  before { Setting.min_age = 16 }

  context 'with an invalid date' do
    it { is_expected.to_not allow_values('76.830.10').for(:date_of_birth).with_message(:invalid) }
  end

  context 'with a date below age limit' do
    let(:too_young) { 13.years.ago.strftime('%d.%m.%Y') }

    it { is_expected.to_not allow_values(too_young).for(:date_of_birth).with_message(:below_limit) }
  end

  context 'with a date above age limit' do
    let(:exact_age) { 16.years.ago.strftime('%d.%m.%Y') }

    it { is_expected.to allow_values(exact_age).for(:date_of_birth) }
  end
end
