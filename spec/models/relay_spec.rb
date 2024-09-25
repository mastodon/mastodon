# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Relay do
  describe 'Normalizations' do
    describe 'inbox_url' do
      it { is_expected.to normalize(:inbox_url).from('  http://host.example  ').to('http://host.example') }
    end
  end
end
