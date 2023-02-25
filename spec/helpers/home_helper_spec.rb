# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeHelper, type: :helper do
  describe 'default_props' do
    it 'returns default properties according to the context' do
      expect(helper.default_props).to eq locale: I18n.locale
    end
  end
end
