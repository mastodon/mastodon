require 'rails_helper'

RSpec.describe ProcessInteractionService do
  subject { ProcessInteractionService.new }

  it 'creates account for new remote user'
  it 'updates account for existing remote user'
  it 'ignores envelopes that do not address the local user'
  it 'accepts a status that mentions the local user'
  it 'accepts a status that is a reply to the local user\'s'
  it 'accepts a favourite to a status by the local user'
  it 'accepts a reblog of a status of the local user'
  it 'accepts a follow of the local user'
  it 'accepts an unfollow of the local user'
end
