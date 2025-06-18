# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RuleTranslation do
  describe 'Associations' do
    it { is_expected.to belong_to(:rule) }
  end

  describe 'Validations' do
    subject { Fabricate.build :rule_translation }

    it { is_expected.to validate_presence_of(:language) }
    it { is_expected.to validate_presence_of(:text) }
    it { is_expected.to validate_length_of(:text).is_at_most(Rule::TEXT_SIZE_LIMIT) }
    it { is_expected.to validate_uniqueness_of(:language).scoped_to(:rule_id) }
  end
end
