require 'rails_helper'

RSpec.describe FollowRemoteAccountService do
  subject { FollowRemoteAccountService.new }

  it 'returns nil if no such user can be resolved via webfinger'
  it 'returns nil if the domain does not have webfinger'
  it 'returns nil if remote user does not offer a hub URL'
  it 'returns an already existing remote account'
  it 'returns a new remote account'
  it 'fills the remote account with profile information'
end
