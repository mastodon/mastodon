require 'spec_helper_integration'

feature 'Authorized applications' do
  background do
    @user   = User.create!(name: 'Joe', password: 'sekret')
    @client = client_exists(name: 'Amazing Client App')
    resource_owner_is_authenticated @user
    client_is_authorized @client, @user
  end

  scenario 'display user\'s authorized applications' do
    visit '/oauth/authorized_applications'
    i_should_see 'Amazing Client App'
  end

  scenario 'do not display other user\'s authorized applications' do
    client = client_exists(name: 'Another Client App')
    client_is_authorized client, User.create!(name: 'Joe', password: 'sekret')
    visit '/oauth/authorized_applications'
    i_should_not_see 'Another Client App'
  end

  scenario 'user revoke access to application' do
    visit '/oauth/authorized_applications'
    i_should_see 'Amazing Client App'
    click_on 'Revoke'
    i_should_see 'Application revoked'
    i_should_not_see 'Amazing Client App'
  end
end
