require 'rails_helper'

describe Admin::FilterHelper do
  it 'Uses table_link_to to create icon links' do
    result = helper.table_link_to 'icon', 'text', 'path'

    expect(result).to match(/text/)
  end
end
