# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateOfBirthValidator do
  subject { Fabricate.build :user }

  before { Setting.min_age = 16 }

  context 'with an invalid date' do
    let(:invalid_date) { '76.830.10' }

    it { is_expected.to_not allow_values(invalid_date).for(:date_of_birth).with_message(:blank) }
  end

  context 'with a date below the age limit' do
    let(:too_young) { 13.years.ago }

    it { is_expected.to_not allow_values(too_young).for(:date_of_birth).with_message(:below_limit) }
  end

  context 'with a date above the age limit' do
    let(:old_enough) { 16.years.ago }

    it { is_expected.to allow_values(old_enough).for(:date_of_birth) }
  end
end
