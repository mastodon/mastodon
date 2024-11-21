# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tombstone do
  describe 'Associations' do
    it { is_expected.to belong_to(:account).required }
  end

  describe 'Validations' do
    subject { Fabricate.build :tombstone }

    it { is_expected.to validate_presence_of(:uri) }
  end
end
