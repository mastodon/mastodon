require 'rails_helper'

RSpec.describe FetchLinkCardService do
  before do
    stub_request(:get, 'http://example.xn--fiqs8s/').to_return(request_fixture('idn.txt'))
  end

  it 'works with IDN URLs' do
    status = Fabricate(:status, text: 'Check out http://example.中国')

    FetchLinkCardService.new.call(status)
    expect(a_request(:get, 'http://example.xn--fiqs8s/')).to have_been_made
  end
end
