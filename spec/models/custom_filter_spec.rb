# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomFilter do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:context) }

    it { is_expected.to_not allow_values([], %w(invalid)).for(:context) }
  end

  describe 'Normalizations' do
    describe 'context' do
      it { is_expected.to normalize(:context).from(['home', 'notifications', 'public    ', '']).to(%w(home notifications public)) }
    end
  end
end
