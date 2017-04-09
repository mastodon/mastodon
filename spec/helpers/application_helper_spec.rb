require 'rails_helper'

describe ApplicationHelper do
  describe 'active_nav_class' do
    it 'returns active when on the current page' do
      allow(helper).to receive(:current_page?).and_return(true)

      result = helper.active_nav_class("/test")
      expect(result).to eq "active"
    end

    it 'returns empty string when not on current page' do
      allow(helper).to receive(:current_page?).and_return(false)

      result = helper.active_nav_class("/test")
      expect(result).to eq ""
    end
  end
end
