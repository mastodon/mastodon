require 'rails_helper'

RSpec.describe HomeHelper, type: :helper do
  describe 'default_props' do
    it 'returns default properties according to the context' do
      expect(helper.default_props).to eq locale: :en
    end
  end
end
