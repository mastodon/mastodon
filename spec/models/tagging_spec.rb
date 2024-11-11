# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tagging do
  describe 'Associations' do
    it { is_expected.to belong_to(:tag).required }
    it { is_expected.to belong_to(:taggable).required }
  end
end
