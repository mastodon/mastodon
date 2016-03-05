require 'rails_helper'

RSpec.describe FollowService do
  subject { FollowService.new }

  it 'creates a following relation'
  it 'creates local account for remote user'
  it 'sends follow to the remote user'
end
