# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeaturedTag do
  describe 'Normalizations' do
    describe 'name' do
      it { is_expected.to normalize(:name).from('  #hashtag  ').to('hashtag') }
    end
  end
end
