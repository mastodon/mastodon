# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountAlias do
  describe 'Normalizations' do
    describe 'acct' do
      it { is_expected.to normalize(:acct).from('  @username@domain  ').to('username@domain') }
    end
  end
end
