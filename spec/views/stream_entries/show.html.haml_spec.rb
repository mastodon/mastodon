require 'rails_helper'

describe 'accounts/show.html.haml' do
  before do
    def view.single_user_mode?
      false
    end
  end

  it 'has an h-feed with correct number of h-entry objects in it' do
    alice = Fabricate(:account, username: 'alice', display_name: 'Alice')
    Fabricate(:status, account: alice, text: 'Hello World')
    Fabricate(:status, account: alice, text: 'Hello World Again')
    Fabricate(:status, account: alice, text: 'Are You Still There World?')

    assign(:account, alice)
    assign(:statuses, alice.statuses)

    render(template: 'accounts/show.html.haml')

    expect(Nokogiri::HTML(rendered).search('.h-feed .h-entry').size).to eq 3
  end
end
