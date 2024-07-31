# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tagging do
  describe 'Validations' do
    it 'validates presence of something' do
      expect(subject).to_not be_valid
    end
  end
end
