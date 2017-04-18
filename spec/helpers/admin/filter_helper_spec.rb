require 'rails_helper'

describe Admin::FilterHelper do
  it 'Uses filter_link_to to create filter links' do
    params = ActionController::Parameters.new(
      { test: 'test' }
    )
    allow(helper).to receive(:params).and_return(params)
    allow(helper).to receive(:url_for).and_return('/test')
    result = helper.filter_link_to('text', { resolved: true })

    expect(result).to match(/text/)
  end

  it 'Uses table_link_to to create icon links' do
    result = helper.table_link_to 'icon', 'text', 'path'

    expect(result).to match(/text/)
  end
end
