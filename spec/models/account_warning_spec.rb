# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountWarning do
  describe 'Normalizations' do
    describe 'text' do
      it { is_expected.to normalize(:text).from(nil).to('') }
    end
  end
end
